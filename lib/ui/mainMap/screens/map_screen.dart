import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../bloc/location/location_block.dart';
import '../../../bloc/location/location_event.dart';
import '../../../bloc/location/location_state.dart';
import '../../../bloc/point/point_block.dart';
import '../../../bloc/point/point_event.dart';
import '../../../bloc/point/point_state.dart';
import '../../../bloc/user/user_block.dart';
import '../../../bloc/user/user_event.dart';
import '../../../bloc/user/user_state.dart';
import '../../../data/mappers/photo_mapper.dart';
import '../../../data/models/place.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/user.dart';
import '../../friends/screens/seach_user_screen.dart';
import '../widgets/auth_sliding_panel.dart';
import '../widgets/sliding_panel_body.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  double currentDeviceHeight = 0;
  double currentDeviceWidth = 0;
  final PanelController _authPanelController = PanelController();
  YandexMapController? _mapController;
  final PanelController _panelController = PanelController();
  final PageController _pageController = PageController();
  List<Place> userPoints = [];
  Point? userLocation;
  User currentUser =
      User(id: 0, email: '', username: '', jwt: '', isAuthorized: false);

  late LocationBloc locationBloc;
  late UserBloc userBloc;
  late PointBloc pointBloc;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    //pointBloc.close();
    //locationBloc.close();
    _mapController?.dispose();
    context.read<LocationBloc>().add(StopLocationUpdateTimerEvent());
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    pointBloc = BlocProvider.of<PointBloc>(context);
  }

  Future<void> _initializeScreen() async {
    locationBloc = context.read<LocationBloc>();
    userBloc = context.read<UserBloc>();
    pointBloc = context.read<PointBloc>();
    locationBloc.add(LoadUserLocationEvent());
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = await prefs.getString('email') ?? '';
    String password = await prefs.getString('password') ?? '';
    userBloc.add(LoginUserEvent(email: email, password: password));
  }

  @override
  Widget build(BuildContext context) {
    currentDeviceHeight = MediaQuery.sizeOf(context).height;
    currentDeviceWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<LocationBloc, LocationState>(
            builder: (context, locationState) {
              return Stack(children: [
                BlocBuilder<PointBloc, PointState>(
                  builder: (context, pointState) {
                    final userLocation = _extractUserLocation(locationState);
                    final points = _extractPoints(pointState);
                    final temporaryPoint = _extractTemporaryPoint(pointState);
                    return _mapBuilder(userLocation, points, temporaryPoint);
                  },
                ),
              ]);
            },
          ),
          _locationButtonBuilder(),
          _navigationButtons(),
          BlocBuilder<PointBloc, PointState>(
            builder: (context, state) {
              return Stack(
                children: [
                  _pageViewBulder(state),
                  _slidingUpPanelBuilder(state)
                ],
              );
            },
          ),
          BlocBuilder<UserBloc, UserState>(
            builder: (context, userState) {
              if (userState is UserErrorState ||
                  userState is UserLoggedOutState) {
                _panelController.close();
                currentUser.email = '';
                currentUser.jwt = '';
                currentUser.isAuthorized = false;
                pointBloc.add(LoadPointsEvent(''));
                userBloc.add(InitialUserEvent());
              } else if (userState is UserLoadedState) {
                currentUser.email = userState.user.email;
                currentUser.jwt = userState.user.jwt;
                currentUser.isAuthorized = true;
                userBloc.add(InitialUserEvent());
                pointBloc.add(LoadPointsEvent(userState.user.jwt));
              }
              return const SizedBox.shrink();
            },
          ),
          BlocBuilder<PointBloc, PointState>(
            builder: (context, state) {
              if (state is PointsLoadingState) {
                return _buildLoadingOverlay();
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          SlidingPanelWidget(
            panelController: _authPanelController,
            currentUser: currentUser,
          ),
        ],
      ),
      // bottomNavigationBar: _bottonMenuBuilder(),
    );
  }

  Widget _navigationButtons() {
    return Positioned(
        top: currentDeviceHeight * 0.08,
        left: 10,
        child: Column(children: [
          Container(
              height: 50,
              width: 50,
              child: FloatingActionButton(
                heroTag: 'UserAcc_Button',
                shape: CircleBorder(),
                backgroundColor: Colors.white,
                mini: true,
                onPressed: () {
                  _authPanelController.open();
                },
                child: const Icon(
                  Icons.face,
                  size: 27,
                ),
              )),
          const SizedBox(
            height: 10,
          ),
          Container(
              height: 50,
              width: 50,
              child: FloatingActionButton(
                heroTag: 'SearchUserScreen_Button',
                shape: CircleBorder(),
                backgroundColor: Colors.white,
                mini: true,
                onPressed: () async {
                  if (currentUser.isAuthorized) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SearchPeopleScreen(currentUser: currentUser),
                      ),
                    );
                  } else {
                    _panelController.animatePanelToPosition(0.17,
                        duration: Duration(milliseconds: 200));
                    Fluttertoast.showToast(
                      msg:
                          "Для продолжения работы необходимо авторизоваться в приложении",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.TOP,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                },
                child: const Icon(
                  Icons.people,
                  size: 27,
                ),
              )),
        ]));
  }

  bool _isDialogVisible = false;

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                strokeWidth: 4.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              const SizedBox(height: 15),
              const Text(
                'Загрузка данных...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                'Пожалуйста, подождите, пока мы находим ваше местоположение.',
                style: TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              AbsorbPointer(
                absorbing: true,
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pageViewBulder(PointState s1) {
    if (s1 is PointsLoadedState) {
      userPoints = s1.points;
    }
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: userPoints.isNotEmpty ? currentDeviceHeight * 0.15 : 0,
      child: Container(
        decoration: BoxDecoration(),
        child: PageView.builder(
          controller: _pageController,
          itemCount: userPoints.length,
          itemBuilder: (context, index) {
            final point = userPoints[index];
            return GestureDetector(
              onTap: () {
                pointBloc.add(SelectPointEvent(index));
                _panelController.open();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: currentDeviceWidth * 0.02,
                    vertical: currentDeviceHeight * 0.01),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 3,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(
                        top: 10, left: 15, bottom: 10, right: 15),
                    child: Row(
                      children: [
                        point.photosMain.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: point.photosMain[0].isLocal()
                                    ? Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Image.file(
                                            File(point.photosMain[0].filePath),
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
                                                Container(
                                                    color: Colors.grey.shade300,
                                                    child: const Icon(Icons
                                                        .image_not_supported))))
                                    : Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Image.network(
                                          point.photosMain[0].filePath,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            color: Colors.grey.shade300,
                                            child: const Icon(
                                                Icons.image_not_supported),
                                          ),
                                        ),
                                      ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.image,
                                  size: 50,
                                ),
                              ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                point.name.trim() == ''
                                    ? 'Название отсутствует'
                                    : point.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                softWrap: true,
                                overflow: TextOverflow.visible,
                              ),
                              Expanded(
                                  child: Text(
                                point.description.trim() == ''
                                    ? 'Описание отсутствует'
                                    : point.description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                softWrap: true,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),
                            ],
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
            _moveCameraToPoint(
                _mapController, userPoints[index].placeLocation, false, 0.5);
            pointBloc.add(SelectPointEvent(index));
          },
        ),
      ),
    );
  }

  bool isPanelOpen = false;

  Point? _extractUserLocation(LocationState locationState) {
    if (locationState is LocationUpdated) {
      _moveCameraToPoint(_mapController, locationState.userLocation, true, 0.5);
      return locationState.userLocation;
    } else if (locationState is BackLocationUpdated) {
      return locationState.userLocation;
    } else if (locationState is LocationLoaded) {
      return locationState.userLocation;
    } else if (locationState is LocationIdle) {
      return locationState.userLocation;
    }
    return null;
  }

  List<Place> _extractPoints(PointState pointState) {
    if (pointState is PointsLoadedState) {
      return pointState.points;
    }
    return [];
  }

  Place? _extractTemporaryPoint(PointState pointState) {
    if (pointState is PointsLoadedState) {
      return pointState.temporaryPoint;
    }
    return null;
  }

  Widget _mapBuilder(
      Point? userLocation, List<Place> points, Place? temporaryPoint) {
    return YandexMap(
      fastTapEnabled: true,
      mode2DEnabled: true,
      onMapCreated: (controller) {
        _mapController = controller;
        if (userLocation != null) {
          _moveCameraToPoint(_mapController, userLocation, true, 0.5);
        }
      },
      mapType: MapType.vector,
      onMapTap: (point) {
        try {
          _moveCameraToPoint(_mapController, point, false, 0.5);

          if (currentUser.isAuthorized) {
            _panelController.animatePanelToPosition(0.17,
                duration: Duration(milliseconds: 200));
            pointBloc.add(CreateTemporaryPointEvent(
              point.latitude,
              point.longitude,
            ));
          } else {
            Fluttertoast.showToast(
              msg:
                  "Для продолжения работы необходимо авторизоваться в приложении",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
          setState(() {
            _isDialogVisible = true;
          });
        } catch (e) {
          print(e);
        }
      },
      mapObjects: _createMapObjects(points, temporaryPoint, userLocation),
    );
  }

  Widget _slidingUpPanelBuilder(PointState state) {
    if (state is PointsLoadedState) {
      return SlidingUpPanel(
        controller: _panelController,
        minHeight: 0,
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        backdropEnabled: isPanelOpen,
        backdropTapClosesPanel: false,
        renderPanelSheet: true,
        color: Colors.transparent,
        panel: SlidingPanelBodyWidget(
          authPanelController: _authPanelController,
          state: state,
          panelController: _panelController,
          currentUser: currentUser,
          pointBloc: pointBloc,
          isDialogVisible: _isDialogVisible,
          isPanelOpen: isPanelOpen,
        ),
        //_buildSlidingPanel(state),
        onPanelOpened: () {
          final point = _getPointForPanel(state);
          setState(() {
            isPanelOpen = true;
          });
          if (point != null) {
            _moveCameraToPoint(
                _mapController, point.placeLocation, false, null);
          }
        },
        onPanelClosed: () {
          setState(() {
            isPanelOpen = false;
          });
          if (_isTemporaryPoint(state)) {
            pointBloc.add(CancelTemporaryPointEvent());
          }
        },
      );
    }
    return const SizedBox.shrink();
  }

  bool _isTemporaryPoint(PointState state) {
    return state is PointsLoadedState && state.temporaryPoint != null;
  }

  Place? _getPointForPanel(PointState state) {
    if (state is PointsLoadedState) {
      return state.temporaryPoint ?? state.selectedPoint;
    }
    return null;
  }

  Widget _locationButtonBuilder() {
    return Positioned(
      bottom: userPoints.isNotEmpty || _isDialogVisible
          ? currentDeviceHeight * 0.16
          : currentDeviceHeight * 0.04,
      right: 10,
      child: Container(
          height: 50,
          width: 50,
          child: FloatingActionButton(
            heroTag: 'CurrLoc_Button',
            shape: CircleBorder(),
            backgroundColor: Colors.white,
            mini: true,
            onPressed: () {
              locationBloc.add(UpdateUserLocationEvent());
            },
            child: const Icon(
              Icons.location_searching,
              size: 27,
            ),
          )),
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
          Text(label,
              style: const TextStyle(color: Colors.black, fontSize: 12)),
        ],
      ),
    );
  }

  Place movedPoint = Place(
      id: "0",
      photosMain: [],
      placeLocation: Point(latitude: 0, longitude: 0),
      name: "name",
      description: "",
      isPointTemporay: false,
      isSelected: false);
  Point movedCoord = Point(latitude: 0, longitude: 0);

  List<PlacemarkMapObject> _createMapObjects(
      List<Place> points, Place? temporaryPoint, Point? userLocation) {
    final mapObjects = points.asMap().entries.map((entry) {
      return PlacemarkMapObject(
        mapId: MapObjectId('placemark_${entry.key}'),
        point: Point(
          latitude: entry.value.placeLocation.latitude,
          longitude: entry.value.placeLocation.longitude,
        ),
        consumeTapEvents: true,
        isDraggable: true,
        onDragEnd: (object) {
          movedPoint.placeLocation = movedCoord;
          pointBloc.add(UpdatePointEvent(
              movedPoint.copyWith(
                  photosMain: movedPoint.photosMain,
                  name: movedPoint.name,
                  description: movedPoint.description,
                  placeLocation: movedCoord,
                  id: movedPoint.id),
              currentUser));
        },
        onDragStart: (object) {
          movedPoint = points.firstWhere((pointUser) =>
              pointUser.placeLocation.latitude == object.point.latitude &&
              pointUser.placeLocation.longitude == object.point.longitude);
          final currentIndex = points.indexOf(movedPoint);
          pointBloc.add(SelectPointEvent(currentIndex));
          /*  _pageController.jumpToPage(
            currentIndex,
          );*/
          _panelController.close();
        },
        onDrag: (object, point) {
          movedCoord = point;
        },
        onTap: (object, point) {
          _panelController.close();
          final currentPoint = points.firstWhere((pointUser) =>
              pointUser.placeLocation.latitude == object.point.latitude &&
              pointUser.placeLocation.longitude == object.point.longitude);
          final currentIndex = points.indexOf(currentPoint);
          _moveCameraToPoint(_mapController, object.point, false, 0.5);
          _pageController.jumpToPage(
            currentIndex,
          );
          pointBloc.add(SelectPointEvent(currentIndex));
        },
        opacity: entry.value.isSelected ? 1 : 0.7,
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            anchor: Offset(0.5, 1.0),
            image: BitmapDescriptor.fromAssetImage('assets/icons/locNew.png'),
            scale: entry.value.isSelected ? 0.45 : 0.3,
          ),
        ),
      );
    }).toList();
    if (temporaryPoint != null && currentUser.isAuthorized) {
      mapObjects.add(
        PlacemarkMapObject(
            mapId: MapObjectId('temporary_placemark'),
            point: Point(
              latitude: temporaryPoint.placeLocation.latitude,
              longitude: temporaryPoint.placeLocation.longitude,
            ),
            isDraggable: true,
            onDragEnd: (object) {
              temporaryPoint.placeLocation = movedCoord;
              movedPoint.placeLocation = movedCoord;
              /*    pointBloc.add(UpdatePointEvent(
                  movedPoint.copyWith(
                      photosMain: movedPoint.photosMain,
                      name: movedPoint.name,
                      description: movedPoint.description,
                      placeLocation: movedCoord,
                      id: movedPoint.id),
                  currentUser));*/
            },
            onDrag: (object, point) {
              movedCoord = point;
            },
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                anchor: Offset(0.5, 1.0),
                image: BitmapDescriptor.fromAssetImage(
                    'assets/icons/location.png'),
                scale: 0.15,
              ),
            ),
            opacity: 1),
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
}
