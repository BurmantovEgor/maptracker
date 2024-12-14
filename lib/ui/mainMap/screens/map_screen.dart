import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_tracker/data/dto/UserDTO.dart';
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
import '../../friends/screens/friends_screnn.dart';
import '../../settings/screens/settings_screen.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  YandexMapController? _mapController;
  YandexMapController? _miniMapController;
  final PanelController _panelController = PanelController();
  final PageController _pageController = PageController();
  List<Place> userPoints = [];
  Point? userLocation = null;
  User currentUser =
      User(id: 0, email: '', username: '', jwt: '', isAuthorized: false);

  UserDTO curUserDTO = UserDTO();

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    pointBloc.close();

    context.read<LocationBloc>().add(StopLocationUpdateTimerEvent());
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    pointBloc = BlocProvider.of<PointBloc>(context);
  }

  @override
  bool get wantKeepAlive => true;

  late LocationBloc locationBloc;
  late UserBloc userBloc;
  late PointBloc pointBloc;

  Future<void> _initializeScreen() async {
    locationBloc = context.read<LocationBloc>();
    userBloc = context.read<UserBloc>();
    pointBloc = context.read<PointBloc>();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    locationBloc.add(LoadUserLocationEvent());
    curUserDTO.email = prefs.getString('email') ?? '';
    curUserDTO.password = prefs.getString('password') ?? '';
    userBloc.add(
        LoginUserEvent(email: curUserDTO.email, password: curUserDTO.password));

    userBloc.stream.listen((userState) {
      if (userState is UserLoadedState) {
        currentUser.email = userState.user.email;
        currentUser.jwt = userState.user.jwt;
        currentUser.isAuthorized = true;
        pointBloc.add(LoadPointsEvent(userState.user.jwt));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          BlocBuilder<PointBloc, PointState>(
            builder: (context, state) {
              return Stack(
                children: [
                  _pageViewBulder(state),
                  _addCardBuilder(state),
                  _slidingUpPanelBuilder(state),
                ],
              );
            },
          ),
          BlocBuilder<UserBloc, UserState>(
            builder: (context, userState) {
              if (userState is UserErrorState) {
                Fluttertoast.showToast(
                  msg: "Необходимо авторизоваться в приложении",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      bottomNavigationBar: _bottonMenuBuilder(),
    );
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

  Widget _bottonMenuBuilder() {
    return Positioned(
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
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SearchPeopleScreen(
                              currentUser: currentUser,
                            )),
                  );
                },
              ),
              _bottomBarItem(
                context,
                icon: Icons.settings,
                label: 'Настройки',
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()),
                  );
                  if (result != null && result is User) {
                    currentUser = result;
                  }
                },
              ),
            ],
          ),
        ));
  }

  ValueNotifier<bool> isLoading = ValueNotifier(true);

  Widget _pageViewBulder(PointState s1) {
    if (s1 is PointsLoadedState) {
      userPoints = s1.points;
    }
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: userPoints.isNotEmpty ? 140 : 0,
      child: Container(
        decoration: BoxDecoration(),
        child: PageView.builder(
          controller: _pageController,
          itemCount: userPoints.length,
          itemBuilder: (context, index) {
            final point = userPoints[index];
            return GestureDetector(
              onTap: () {
                _moveCameraToPoint(_miniMapController,
                    userPoints[index].placeLocation, false, null);
                pointBloc.add(SelectPointEvent(index));
                _panelController.open();
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(
                        top: 10, left: 15, bottom: 10, right: 15),
                    child: Row(
                      children: [
                        point.photosMain.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: point.photosMain[0].isLocal()
                                    ? Stack(children: [
                                        Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                    Color>(Colors.grey),
                                            strokeWidth: 6.0,
                                            backgroundColor:
                                                Colors.grey.shade300,
                                          ),
                                        ),
                                        Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Image.file(
                                                File(point
                                                    .photosMain[0].filePath),
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Container(
                                                        color: Colors
                                                            .grey.shade300,
                                                        child: const Icon(Icons
                                                            .image_not_supported))))
                                      ])
                                    : Stack(children: [
                                        Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                    Color>(Colors.grey),
                                            strokeWidth: 6.0,
                                            backgroundColor:
                                                Colors.grey.shade300,
                                          ),
                                        ),
                                        Container(
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
                                      ]))
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

  Widget _addCardBuilder(PointState state) {
    if (state is PointsLoadedState) {
      print('я сбилдил аддкарт');
      return Positioned(
          bottom: 60,
          left: 0,
          right: 0,
          height: _isDialogVisible ? 140 : 0,
          child: AnimatedOpacity(
            opacity: _isDialogVisible ? 1.0 : 0.0,
            duration: userPoints.isEmpty
                ? const Duration(milliseconds: 200)
                : const Duration(milliseconds: 0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: currentUser.isAuthorized
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _panelController.open();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.grey.shade600,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 15),
                                      elevation: 5,
                                    ),
                                    child: const Text(
                                      'Добавить точку',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _isDialogVisible = false;
                                      });
                                      if (state.temporaryPoint != null) {
                                        pointBloc
                                            .add(CancelTemporaryPointEvent());
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.grey.shade600,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 15),
                                      elevation: 5,
                                    ),
                                    child: const Text(
                                      'Отменить',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SettingsScreen()),
                                      );
                                      if (result != null && result is User) {
                                        currentUser = result;
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.grey.shade600,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 15),
                                      elevation: 5,
                                    ),
                                    child: const Text(
                                      'Войти',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ));
    }
    return const SizedBox.shrink();
  }

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
        pointBloc.add(CreateTemporaryPointEvent(
          point.latitude,
          point.longitude,
        ));
        _moveCameraToPoint(_mapController, point, false, 0.5);
        _moveCameraToPoint(_miniMapController, point, false, null);
        setState(() {
          _isDialogVisible = true;
        });
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
        backdropEnabled: true,
        backdropTapClosesPanel: false,
        renderPanelSheet: true,
        color: Colors.transparent,
        panel: _buildSlidingPanel(state),
        onPanelOpened: () {
          setState(() {
            _isDialogVisible = false;
          });
          final point = _getPointForPanel(state);
          if (point != null) {
            _moveCameraToPoint(
                _mapController, point.placeLocation, false, null);
            _moveCameraToPoint(
                _miniMapController, point.placeLocation, false, null);
          }
        },
        onPanelClosed: () {
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
      bottom: userPoints.isNotEmpty || _isDialogVisible ? 210 : 60,
      right: 10,
      child: FloatingActionButton(
        mini: true,
        onPressed: () {
          locationBloc.add(UpdateUserLocationEvent());
        },
        child: const Icon(Icons.location_searching),
      ),
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
      List<Place> points, Place? temporaryPoint, Point? userLocation) {
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

  final ImagePicker _picker = ImagePicker();

  Widget _buildSlidingPanel(PointsLoadedState state) {
    final temporaryPoint = state.temporaryPoint;
    final selectedPoint = state.selectedPoint;
    Place? point = temporaryPoint ?? selectedPoint;
    final isTemporary = temporaryPoint != null;

    final nameController = TextEditingController(text: point?.name ?? '');
    final descriptionController =
        TextEditingController(text: point?.description ?? '');
    return Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25)),
          color: Colors.white,
        ),
        child: Stack(
          children: [
            StatefulBuilder(
              builder: (context, setState) {
                return GestureDetector(
                  onVerticalDragEnd: (details) {
                    if (_panelController.isAttached &&
                        details.primaryVelocity! > 0) {
                      _panelController.close();
                    }
                  },
                  child: SingleChildScrollView(
                      physics: ClampingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, top: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                SizedBox(
                                  height: 200,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      'https://static-maps.yandex.ru/1.x/?ll=${point?.placeLocation.longitude},${point?.placeLocation.latitude}&z=14&l=map&size=500,200',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 140,
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    'assets/icons/location.png',
                                    width: 60,
                                    height: 60,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: nameController,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Добавьте название...',
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                contentPadding: const EdgeInsets.all(12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              minLines: 1,
                              maxLines: 2,
                              maxLength: 40,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: descriptionController,
                              scrollPhysics:
                                  const NeverScrollableScrollPhysics(),
                              decoration: InputDecoration(
                                hintText: 'Добавьте описание...',
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                contentPadding: EdgeInsets.all(12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              minLines: 1,
                              maxLines: 9,
                              maxLength: 750,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Фотографии',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: point!.photosMain.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 100,
                                    margin: EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.grey.shade200,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: point.photosMain[index].isLocal()
                                          ? Image.file(
                                              File(point
                                                  .photosMain[index].filePath),
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Container(
                                                      color:
                                                          Colors.grey.shade300,
                                                      child: const Icon(Icons
                                                          .image_not_supported)))
                                          : Image.network(
                                              point.photosMain[index].filePath,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Container(
                                                color: Colors.grey.shade300,
                                                child: const Icon(
                                                    Icons.image_not_supported),
                                              ),
                                            ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async {
                                final pickedFile =
                                    await _picker.pickMultiImage();
                                if (pickedFile != null) {
                                  setState(() {
                                    point.photosMain.addAll(
                                        PhotoMapper.fromXFiles(pickedFile));
                                  });
                                }
                              },
                              child: Text('Добавить фото'),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.all(16),
                                    backgroundColor: Colors.grey.shade300,
                                  ),
                                  onPressed: () {
                                    if (isTemporary) {
                                      pointBloc
                                          .add(CancelTemporaryPointEvent());
                                    } else {
                                      pointBloc.add(RemovePointEvent());
                                    }
                                    _panelController.close();
                                  },
                                  child:
                                      Icon(Icons.delete, color: Colors.black),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.all(16),
                                    backgroundColor: Colors.grey.shade300,
                                  ),
                                  onPressed: () {
                                    if (nameController.text.trim() == '' &&
                                        descriptionController.text.trim() ==
                                            '') {
                                      Fluttertoast.showToast(
                                        msg:
                                            "Необходимо заполнить одно из полей",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.black,
                                        textColor: Colors.white,
                                        fontSize: 16.0,
                                      );
                                    } else {
                                      if (isTemporary) {
                                        pointBloc.add(SaveTemporaryPointEvent(
                                            point.copyWith(
                                                name: nameController.text,
                                                description:
                                                    descriptionController.text,
                                                photosMain: point.photosMain),
                                            currentUser));
                                      } else {
                                        pointBloc.add(
                                          UpdatePointEvent(
                                              point.copyWith(
                                                  name: nameController.text,
                                                  description:
                                                      descriptionController
                                                          .text,
                                                  photosMain: point.photosMain),
                                              currentUser),
                                        );
                                      }
                                      _panelController.close();
                                    }
                                  },
                                  child: const Icon(Icons.save,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                );
              },
            ),
            Container(
              width: double.infinity,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(25),
                    topLeft: Radius.circular(25)),
              ),
              child: Center(
                child: Container(
                  width: 70,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ));
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
