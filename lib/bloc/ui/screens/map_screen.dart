import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../data/models/Location.dart';
import '../../point/point_block.dart';
import '../../point/point_event.dart';
import '../../point/point_state.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  YandexMapController? _mapController;
  final PanelController _panelController = PanelController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<PointBloc>(context).add(LoadPointsEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Карта')),
      body: BlocBuilder<PointBloc, PointState>(
        builder: (context, state) {
          if (state is PointsInitialState) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is PointsLoadedState) {
            List<CustomPoint> points = state.points;
            int selectedIndex = state.selectedIndex;

            if (_mapController != null && points.isNotEmpty) {
              _moveToSelectedPoint(points[selectedIndex].latitude,
                  points[selectedIndex].longitude);
            }
            return Stack(
              children: [
                YandexMap(
                  onMapCreated: (controller) {
                    _mapController = controller;
                    if (points.isNotEmpty) {
                      _moveToSelectedPoint(points[selectedIndex].latitude,
                          points[selectedIndex].longitude);
                    }
                  },
                  onMapTap: (point) {
                    BlocProvider.of<PointBloc>(context)
                        .add(CreateTemporaryPointEvent(
                      point.latitude,
                      point.longitude,
                    ));
                    _moveToSelectedPoint(point.latitude, point.longitude);
                    _panelController.open();
                  },
                  mapObjects: _createMapObjects(points, state.temporaryPoint),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  height: 100,
                  child: PageView.builder(
                    controller: PageController(
                      viewportFraction: 0.8,
                      initialPage: selectedIndex,
                    ),
                    itemCount: points.length,
                    itemBuilder: (context, index) {
                      final point = points[index];
                      return GestureDetector(
                        onTap: () {
                          BlocProvider.of<PointBloc>(context)
                              .add(SelectPointEvent(index));
                          _panelController.open();
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          child: Center(
                            child: Text(
                              point.name,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    },
                    onPageChanged: (index) {
                      /* _moveToSelectedPoint(
                          points[index].latitude, points[index].longitude);*/
                      BlocProvider.of<PointBloc>(context)
                          .add(SelectPointEvent(index));
                    },
                  ),
                ),
                SlidingUpPanel(
                  controller: _panelController,
                  minHeight: 0,
                  maxHeight: 300,
                  panel: _buildSlidingPanel(state),
                ),
              ],
            );
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  List<PlacemarkMapObject> _createMapObjects(
      List<CustomPoint> points, CustomPoint? temporaryPoint) {
    final mapObjects = points.asMap().entries.map((entry) {
      return PlacemarkMapObject(
        mapId: MapObjectId('placemark_${entry.key}'),
        point: Point(
          latitude: entry.value.latitude,
          longitude: entry.value.longitude,
        ),
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            anchor: Offset(0.5, 1.0),
            image: BitmapDescriptor.fromAssetImage('assets/icons/location.png'),
            scale: 0.1,
          ),
        ),
      );
    }).toList();

    // Добавляем временную точку
    if (temporaryPoint != null) {
      mapObjects.add(
        PlacemarkMapObject(
          mapId: MapObjectId('temporary_placemark'),
          point: Point(
            latitude: temporaryPoint.latitude,
            longitude: temporaryPoint.longitude,
          ),
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              anchor: Offset(0.5, 1.0),
              image:
                  BitmapDescriptor.fromAssetImage('assets/icons/location.png'),
              scale: 0.15,
            ),
          ),
        ),
      );
    }
    print("mapObjects Length ${mapObjects.length}");
    for (int i = 0; i < mapObjects.length; i++) {
      print(mapObjects[i].mapId);
      print("\n");
      print(mapObjects[i].point.longitude);
      print("\n");
      print(mapObjects[i].point.latitude);
      print("\n");
      print("\n");
    }
    return mapObjects;
  }

  void _moveToSelectedPoint(double lat, double long) {
    if (_mapController == null) return;
    _mapController!.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(latitude: lat, longitude: long),
          zoom: 10,
        ),
      ),
    );
  }

  Widget _buildSlidingPanel(PointsLoadedState state) {
    final temporaryPoint = state.temporaryPoint;
    final selectedPoint = state.selectedPoint;
    final point = temporaryPoint ?? selectedPoint;
    final isTemporary = temporaryPoint != null;
    final nameController = TextEditingController(text: point?.name ?? '');
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isTemporary ? 'Добавить точку' : 'Редактировать точку',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Название точки',
              border: OutlineInputBorder(),
            ),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  _panelController.close();
                  if (isTemporary) {
                    BlocProvider.of<PointBloc>(context)
                        .add(CancelTemporaryPointEvent());
                  }
                },
                child: Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (isTemporary) {
                    print("test_temp");
                    temporaryPoint.name = nameController.text;
                    BlocProvider.of<PointBloc>(context)
                        .add(SaveTemporaryPointEvent());
                  } else {
                    print("test_nottemp");
                    BlocProvider.of<PointBloc>(context).add(
                      UpdatePointEvent(
                        point!.copyWith(name: nameController.text),
                      ),
                    );
                  }
                  _panelController.close();
                },
                child: Text('Сохранить'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
