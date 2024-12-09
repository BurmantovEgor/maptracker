import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/models/place.dart';
import '../../point/point_block.dart';
import '../../point/point_event.dart';
import '../../point/point_state.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  YandexMapController? _mapController;
  YandexMapController? _miniMapController;
  late Point? _userLocation = null;
  bool _locationLoaded = false;

  final PanelController _panelController = PanelController();
  final PageController _pageController = PageController();
  int _totalPagers = 0;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<PointBloc>(context).add(LoadPointsEvent());
    });
  }
  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
      _userLocation = Point(latitude: position.latitude, longitude: position.longitude);
      _locationLoaded = true;
    _moveToUserLocation();
  }


  void _moveToUserLocation() {
    if (_locationLoaded && _mapController != null) {
      _mapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _userLocation!,
            zoom: 12.0, // Устанавливаем желаемый уровень зума
          ),

        ),
        animation: MapAnimation(type: MapAnimationType.smooth, duration: 0.5),
      );
    }
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
                    if (points.isNotEmpty) {
                      print("POINTTEST Переместился на 1 точку");
                      _moveToSelectedPoint(points[0].placeLocation.latitude,
                          points[0].placeLocation.longitude,
                          isPanelOpen: false);
                    } else {
                      //TODO мув на текущую локацию
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
                    _moveToSelectedPoint(point.latitude, point.longitude,
                        isPanelOpen: true);
                    _moveCameraToPoint(
                        _miniMapController,
                        place(
                            photos: [],
                            placeLocation: Point(
                                latitude: point.latitude,
                                longitude: point.longitude),
                            name: '',
                            description: 'description',
                            isPointTemporay: false,
                            isSelected: false));
                    _panelController.open();
                    print("POINTTEST Установил точку на карте");
                  },
                  mapObjects: _createMapObjects(points, state.temporaryPoint),
                ),
                Positioned(
                  bottom: 140, // Чуть выше PageView
                  right: 10,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        mini: true,
                        onPressed: () async {
                          if (_mapController != null) {
                            final currentPosition =
                                await _mapController!.getCameraPosition();
                            _mapController!.moveCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: currentPosition.target,
                                  zoom: currentPosition.zoom + 1,
                                ),
                              ),
                              animation: const MapAnimation(
                                duration: 0.5,
                              ),
                            );
                          }
                        },
                        child: Icon(Icons.add),
                      ),
                      SizedBox(height: 10),
                      FloatingActionButton(
                        mini: true,
                        onPressed: () async {
                          _getUserLocation();

                          /*
                          if (_mapController != null) {
                            final currentPosition =
                                await _mapController!.getCameraPosition();
                            _mapController!.moveCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: currentPosition.target,
                                  zoom: currentPosition.zoom - 1,
                                ),
                              ),
                              animation: const MapAnimation(
                                duration: 0.5,
                              ),
                            );
                          }*/
                        },
                        child: Icon(Icons.location_searching),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  height: 100,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          // Тень под страницами
                          spreadRadius: 3,
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: /*PageView.builder(
                      controller: _pageController,
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
                        print("POINTTEST Изменил страницу");
                        _moveToSelectedPoint(
                            points[index].placeLocation.latitude,
                            points[index].placeLocation.longitude);
                        BlocProvider.of<PointBloc>(context)
                            .add(SelectPointEvent(index));
                      },
                    ),*/
                        PageView.builder(
                      controller: _pageController,
                      itemCount: points.length,
                      itemBuilder: (context, index) {
                        final point = points[index];
                        return GestureDetector(
                          onTap: () {
                            _moveCameraToPoint(
                                _miniMapController, points[index]);
                            BlocProvider.of<PointBloc>(context)
                                .add(SelectPointEvent(index));
                            _panelController.open();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Card(
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    15), // Закруглённые углы
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Левая часть: имя и описание
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Название точки
                                          Text(
                                            point.name,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 10),

                                          // Описание точки
                                          Text(
                                            point.description ??
                                                'Описание отсутствует',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54,
                                            ),
                                            maxLines: 3, // Ограничиваем строки
                                            overflow: TextOverflow
                                                .ellipsis, // Обрезаем текст
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: point.photos != null &&
                                              point.photos!.isNotEmpty
                                          ? ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: point.photos!.length,
                                              itemBuilder:
                                                  (context, photoIndex) {
                                                final photo =
                                                    point.photos![photoIndex];
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 10),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
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
                                                        color: Colors
                                                            .grey.shade300,
                                                        child: Icon(Icons
                                                            .image_not_supported),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                          : Center(
                                              child: Text(
                                                'Фотографии отсутствуют',
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
                        _moveToSelectedPoint(
                            points[index].placeLocation.latitude,
                            points[index].placeLocation.longitude,
                            isPanelOpen: false);
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
                        _moveCameraToPoint(
                            _miniMapController, state.temporaryPoint);
                      }
                    } else {
                      _moveCameraToPoint(
                          _miniMapController, state.selectedPoint);
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
              ],
            );
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
  Future<BitmapDescriptor> _getCustomIcon(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final List<int> bytes = data.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(Uint8List.fromList(bytes));
  }
  List<PlacemarkMapObject> _createMapObjects(
      List<place> points, place? temporaryPoint) {
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

    // Добавляем временную точку
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
    if(_userLocation != null){
      print('mapObjectCountNotNull:${mapObjects.length}');
      print('mapObjectCountNotNull:${_userLocation!.latitude}');
      print('mapObjectCountNotNull:${_userLocation!.longitude}');
      mapObjects.add(
        PlacemarkMapObject(
          mapId: MapObjectId('UserPlacemark'),
          point: Point(
            latitude: _userLocation!.latitude,
            longitude: _userLocation!.longitude,
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
    print('mapObjectCount:${mapObjects.length}');
    return mapObjects;
  }

  void _moveToSelectedPoint(double lat, double long,
      {bool isPanelOpen = false}) async {
    final cameraPosition = await _mapController!.getCameraPosition();
    _mapController!.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(latitude: lat, longitude: long),
          zoom: cameraPosition.zoom,
        ),
      ),
      animation: MapAnimation(type: MapAnimationType.smooth, duration: 0.5),
    );
  }

  void _moveCameraToPoint(YandexMapController? controller, place? point) {
    if (point != null) {
      controller!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: Point(
              latitude: point.placeLocation.latitude,
              longitude: point.placeLocation.longitude,
            ),
            zoom: 12,
          ),
        ),
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
                  _moveCameraToPoint(_miniMapController, point);
                } else if (temporaryPoint != null) {
                  _moveCameraToPoint(_miniMapController, temporaryPoint);
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
