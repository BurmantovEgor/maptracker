import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../data/models/place.dart';
import '../../../data/user/user_block.dart';
import '../../../data/user/user_event.dart';
import '../../../data/user/user_state.dart';
import '../../../point/point_block.dart';
import '../../../point/point_event.dart';
import '../../../point/point_state.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  YandexMapController? _mapController;
  YandexMapController? _miniMapController;
  final PanelController _panelController = PanelController();
  final PageController _pageController = PageController();
  int _totalPagers = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<PointBloc>(context).add(LoadPointsEvent());
      BlocProvider.of<LocationBloc>(context).add(LoadUserLocationEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Карта')),
      body: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, locationState) {
          if (locationState is LocationLoading) {
            print('loading');
            return Center(child: CircularProgressIndicator());
          }
          if (locationState is LocationError) {
            print('Error');
            return Stack(
              children: [
                _buildMap(null),
                Positioned(
                  bottom: 50,
                  left: 20,
                  right: 20,
                  child: Text(
                    'Ошибка: ${locationState.message}',
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          }
          if (locationState is LocationLoaded) {
            return _buildMap(locationState.userLocation);
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildMap(Point? userLocation) {
    return BlocBuilder<PointBloc, PointState>(
      builder: (context, state) {
        if (state is PointsInitialState) {
          return Center(child: CircularProgressIndicator());
        }
        if (state is PointsLoadedState) {
          print("Я ТУТ");
          List<place> points = state.points;
          _totalPagers = state.points.length;
          int selectedIndex = state.selectedIndex;
          print('selectedIndex: {$selectedIndex}');
          return Stack(
            children: [
              YandexMap(
                onMapCreated: (controller) {
                  _mapController = controller;
                  if (userLocation != null) {
                    _moveCameraToPoint(
                      _mapController,
                      userLocation,
                      true,
                      0.5,
                    );
                  }
                },
                mapType: MapType.vector,
                onMapTap: (point) {
                  BlocProvider.of<PointBloc>(context)
                      .add(CreateTemporaryPointEvent(
                    point.latitude,
                    point.longitude,
                  ));
                  _panelController.open();
                  _moveCameraToPoint(_mapController, point, false, 0.5);
                  _moveCameraToPoint(_miniMapController, point, false, null);
                  _panelController.open();
                },
                mapObjects: _createMapObjects(
                    points, state.temporaryPoint, userLocation),
              ),
              Positioned(
                bottom: points.isNotEmpty ? 240 : 60,
                right: 10,
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    FloatingActionButton(
                      mini: true,
                      onPressed: () async {
                        BlocProvider.of<LocationBloc>(context)
                            .add(LoadUserLocationEvent());
                      },
                      child: Icon(Icons.location_searching),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                height: points.isNotEmpty ? 170 : 0,
                child: Container(
                  decoration: BoxDecoration(),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: points.length,
                    itemBuilder: (context, index) {
                      final point = points[index];
                      return GestureDetector(
                        onTap: () {
                          _moveCameraToPoint(_miniMapController,
                              points[index].placeLocation, false, null);
                          BlocProvider.of<PointBloc>(context)
                              .add(SelectPointEvent(index));
                          _panelController.open();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Container(
                              margin: EdgeInsets.only(top: 10, left: 15),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      softWrap: true,
                                      maxLines: 2,
                                      point.name.trim() == ''
                                          ? 'Название отсутствует'
                                          : point.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    flex: 4,
                                    child: point.photos != null &&
                                            point.photos!.isNotEmpty
                                        ? ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: point.photos!.length,
                                            itemBuilder: (context, photoIndex) {
                                              final photo =
                                                  point.photos![photoIndex];
                                              return Padding(
                                                padding:
                                                    EdgeInsets.only(right: 10),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  // Закругляем фото
                                                  child: Image.network(
                                                    photo, // URL фото
                                                    width: 80,
                                                    height: 80,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        Container(
                                                      width: 80,
                                                      height: 80,
                                                      color:
                                                          Colors.grey.shade300,
                                                      child: Icon(Icons
                                                          .image_not_supported),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : const Center(
                                            child: Text(
                                              'Фотографииn\nотсутствуют',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    onPageChanged: (index) {
                      _moveCameraToPoint(_mapController,
                          points[index].placeLocation, false, 0.5);
                      BlocProvider.of<PointBloc>(context)
                          .add(SelectPointEvent(index));
                    },
                  ),
                ),
              ),
              SlidingUpPanel(
                backdropOpacity: 0.65,
                backdropTapClosesPanel: false,
                backdropEnabled: true,
                controller: _panelController,
                minHeight: 0,
                maxHeight: MediaQuery.sizeOf(context).height * 0.87,
                margin: EdgeInsets.symmetric(horizontal: 10),
                // Сужаем панель по бокам
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                // Закруглённые края
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // Тень под панелью
                    spreadRadius: 5,
                    blurRadius: 15,
                    offset: Offset(0, -5),
                  ),
                ],
                onPanelOpened: () {
                  final isTemporary = state.temporaryPoint != null;
                  if (isTemporary) {
                    if (state.temporaryPoint != null) {
                      _moveCameraToPoint(_miniMapController,
                          state.temporaryPoint!.placeLocation, false, null);
                    }
                  } else {
                    _moveCameraToPoint(_miniMapController,
                        state.selectedPoint!.placeLocation, false, null);
                  }
                },
                onPanelClosed: () {
                  final isTemporary = state.temporaryPoint != null;
                  if (isTemporary) {
                    BlocProvider.of<PointBloc>(context)
                        .add(CancelTemporaryPointEvent());
                  }
                },
                panel: _buildSlidingPanel(state),
              ),
              Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 50,
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _bottomBarItem(
                          context,
                          icon: Icons.map,
                          label: 'Карта',
                          onTap: () {
                            Navigator.pushNamed(context, '/');
                          },
                        ),
                        _bottomBarItem(
                          context,
                          icon: Icons.people,
                          label: 'Поиск',
                          onTap: () {
                            Navigator.pushNamed(context, '/search');
                          },
                        ),
                        _bottomBarItem(
                          context,
                          icon: Icons.settings,
                          label: 'Настройки',
                          onTap: () {
                            Navigator.pushNamed(context, '/settings');
                          },
                        ),
                      ],
                    ),
                  ))
            ],
          );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _bottomBarItem(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.black, size: 24),
          Text(label, style: TextStyle(color: Colors.black, fontSize: 12)),
        ],
      ),
    );
  }

  List<PlacemarkMapObject> _createMapObjects(
      List<place> points, place? temporaryPoint, Point? userLocation) {
    final mapObjects = points.asMap().entries.map((entry) {
      return PlacemarkMapObject(
        mapId: MapObjectId('placemark_${entry.key}'),
        point: Point(
          latitude: entry.value.placeLocation.latitude,
          longitude: entry.value.placeLocation.longitude,
        ),
        /* onTap: (object, point) {
          _moveToSelectedPoint(point.latitude, point.longitude);
        },*/
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            anchor: Offset(0.5, 1.0),
            image: BitmapDescriptor.fromAssetImage('assets/icons/location.png'),
            scale: entry.value.isSelected ? 0.15 : 0.1,
          ),
        ),
      );
    }).toList();
    if (temporaryPoint != null) {
      mapObjects.add(
        PlacemarkMapObject(
          mapId: MapObjectId('temporary_placemark'),
          point: Point(
            latitude: temporaryPoint.placeLocation.latitude,
            longitude: temporaryPoint.placeLocation.longitude,
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
    if (userLocation != null) {
      mapObjects.add(
        PlacemarkMapObject(
          mapId: MapObjectId('UserPlacemark'),
          point: Point(
            latitude: userLocation.latitude,
            longitude: userLocation.longitude,
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
    return mapObjects;
  }

  void _moveCameraToPoint(YandexMapController? controller, Point? point,
      bool moveToUserPosition, double? animTime) async {
    if (point != null) {
      final cameraPosition = await _mapController!.getCameraPosition();
      controller!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: Point(
              latitude: point.latitude,
              longitude: point.longitude,
            ),
            zoom: moveToUserPosition ? 12 : cameraPosition.zoom,
          ),
        ),
        animation: MapAnimation(
            type: MapAnimationType.smooth,
            duration: animTime == null ? 0 : animTime),
      );
    }
  }

  Widget _buildSlidingPanel(PointsLoadedState state) {
    final temporaryPoint = state.temporaryPoint;
    final selectedPoint = state.selectedPoint;
    place? point = temporaryPoint ?? selectedPoint;
    print("checkPoints");
    if (point != null) {
      print(point.placeLocation.longitude);
    }
    final isTemporary = temporaryPoint != null;
    final nameController = TextEditingController(text: point?.name ?? '');
    final descriptionController =
        TextEditingController(text: point?.description ?? '');
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Container(
            height: 150, // Устанавливаем высоту мини-карты
            margin: EdgeInsets.only(bottom: 20),
            child: YandexMap(
              onMapCreated: (controller) {
                print("NewCheckPoint");
                print(point.toString());
                _miniMapController = controller;
                if (point != null) {
                  _moveCameraToPoint(
                      _miniMapController, point.placeLocation, false, null);
                } else if (temporaryPoint != null) {
                  _moveCameraToPoint(_miniMapController,
                      temporaryPoint.placeLocation, false, null);
                }
              },
              mapType: MapType.vector,
              zoomGesturesEnabled: false, // Отключаем возможность зума
              scrollGesturesEnabled: false, // Отключаем возможность перемещения
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(
                icon: Icons.delete,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  if (isTemporary) {
                    BlocProvider.of<PointBloc>(context)
                        .add(CancelTemporaryPointEvent());
                  } else {
                    BlocProvider.of<PointBloc>(context).add(RemovePointEvent());
                  }
                  _panelController.close();
                },
                tooltip: "Удалить",
              ),
              Text(
                isTemporary ? 'Добавить точку' : 'Редактировать точку',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              _buildActionButton(
                icon: Icons.add,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  if (isTemporary) {
                    if (nameController.text.trim() == '' &&
                        descriptionController.text.trim() == '') {
                      Fluttertoast.showToast(
                        msg: "Необходимо заполнить одно из полей",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    } else {
                      temporaryPoint!.name = nameController.text;
                      temporaryPoint.description = descriptionController.text;
                      BlocProvider.of<PointBloc>(context)
                          .add(SaveTemporaryPointEvent());
                      _pageController.jumpToPage(_totalPagers);
                      _panelController.close();
                    }
                  } else {
                    if (nameController.text.trim() == '' &&
                        descriptionController.text.trim() == '') {
                      Fluttertoast.showToast(
                        msg: "Необходимо заполнить одно из полей",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        fontSize: 16.0,
                      );
                    } else {
                      BlocProvider.of<PointBloc>(context).add(
                        UpdatePointEvent(
                          point!.copyWith(
                            name: nameController.text,
                            description: descriptionController.text,
                          ),
                        ),
                      );
                      _panelController.close();
                    }
                  }
                },
                tooltip: "Сохранить",
              ),
            ],
          ),
          SizedBox(height: 20),
          TextField(
            maxLength: 40,
            minLines: 1,
            maxLines: 2,
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Название точки',
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(Icons.place),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            minLines: 1,
            maxLines: 10,
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: 'Описание',
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(Icons.description),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Material(
      color: Colors.grey.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.grey.shade600, size: 24),
        tooltip: tooltip,
      ),
    );
  }
}
