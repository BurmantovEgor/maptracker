import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_tracker/bloc/point/point_event.dart';
import 'package:map_tracker/ui/mainMap/screens/map_screen.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../../bloc/point/point_block.dart';
import '../../../bloc/point/point_state.dart';
import '../../../bloc/user/userSearch_block.dart';
import '../../../bloc/user/userSearch_event.dart';
import '../../../bloc/user/userSearch_state.dart';
import '../../../data/models/place.dart';
import '../../../data/models/user.dart';

class SearchPeopleScreen extends StatefulWidget {
  final User currentUser;

  const SearchPeopleScreen({Key? key, required this.currentUser})
      : super(key: key);

  @override
  _UserSearchScreenState createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<SearchPeopleScreen> {
  final TextEditingController _controller = TextEditingController();

  bool _isDropdownExpanded = false;
  String? _selectedUser;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownExpanded = !_isDropdownExpanded;
      if (_isDropdownExpanded) {
        _controller.clear();
        BlocProvider.of<UserSearchBloc>(context)
            .add(FetchUsersEvent('', widget.currentUser.jwt));
      }
    });
  }

  YandexMapController? _mapController;

  Widget _mapBuilder(List<Place> points) {
    return YandexMap(
      fastTapEnabled: true,
      mode2DEnabled: true,
      onMapCreated: (controller) {
        _mapController = controller;
      },
      mapType: MapType.vector,
      mapObjects: _createMapObjects(points),
    );
  }

  List<PlacemarkMapObject> _createMapObjects(List<Place> points) {
    final mapObjects = points.asMap().entries.map((entry) {
      return PlacemarkMapObject(
        mapId: MapObjectId('placemark_${entry.key}'),
        consumeTapEvents: true,
        point: Point(
          latitude: entry.value.placeLocation.latitude,
          longitude: entry.value.placeLocation.longitude,
        ),
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
          BlocProvider.of<PointBloc>(context)
              .add(SelectPointOtherUserEvent(currentIndex));
        },
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            anchor: Offset(0.5, 1.0),
            image: BitmapDescriptor.fromAssetImage('assets/icons/location.png'),
            scale: entry.value.isSelected ? 0.15 : 0.1,
          ),
        ),
      );
    }).toList();
    return mapObjects;
  }

  List<Place> _extractPoints(PointState pointState) {
    if (pointState is OtherUserPointsLoadedState) {
      return pointState.points;
    }
    return [];
  }

  final PanelController _panelController = PanelController();
  final PageController _pageController = PageController();

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

  Widget _pageViewBulder(PointState s1) {
    late List<Place> userPoints = [];
    if (s1 is OtherUserPointsLoadedState) {
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
                BlocProvider.of<PointBloc>(context)
                    .add(SelectPointOtherUserEvent(index));
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
            BlocProvider.of<PointBloc>(context)
                .add(SelectPointOtherUserEvent(index));
          },
        ),
      ),
    );
  }

  Widget _navigationButtons() {
    return Positioned(
        top: currentDeviceHeight * 0.18,
        left: 10,
        child: Column(children: [
          Container(
              height: 50,
              width: 50,
              child: FloatingActionButton(
                heroTag: 'MainMapScreen_Button',
                shape: CircleBorder(),
                backgroundColor: Colors.white,
                mini: true,
                onPressed: () async {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapScreen(),
                    ),
                  );
                },
                child: const Icon(
                  Icons.home,
                  size: 27,
                  color: Colors.black,
                ),
              )),
        ]));
  }

  double currentDeviceHeight = 0;
  double currentDeviceWidth = 0;

  Place? _getPointForPanel(PointState state) {
    if (state is PointsLoadedState) {
      return state.temporaryPoint ?? state.selectedPoint;
    }
    return null;
  }

  Widget _slidingUpPanelBuilder(PointState state) {
    if (state is OtherUserPointsLoadedState) {
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
          final point = _getPointForPanel(state);
          if (point != null) {
            _moveCameraToPoint(
                _mapController, point.placeLocation, false, null);
          }
        },
      );
    }
    return const SizedBox.shrink();
  }

  int currentPage = 0;

  Widget _buildSlidingPanel(OtherUserPointsLoadedState state) {
    if (state.points.isNotEmpty) {
      Place point = state.points[state.selectedIndex];
      return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: Container(
            color: Colors.white,
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
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              SizedBox(
                                height: MediaQuery.sizeOf(context).height * 0.3,
                                width: MediaQuery.sizeOf(context).width,
                                child: point.photosMain.isEmpty
                                    ? const Center(
                                        child: Icon(
                                          Icons.image,
                                          size: 100,
                                        ),
                                      )
                                    : PageView.builder(
                                        itemCount: point.photosMain.length,
                                        onPageChanged: (index) {
                                          setState(() {
                                            currentPage = index;
                                          });
                                        },
                                        itemBuilder: (context, index) {
                                          return point.photosMain[index]
                                                  .isLocal()
                                              ? Image.file(
                                                  File(point.photosMain[index]
                                                      .filePath),
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.network(
                                                  point.photosMain[index]
                                                      .filePath,
                                                  fit: BoxFit.cover,
                                                );
                                        },
                                      ),
                              ),
                              Positioned(
                                bottom: 30,
                                left: 80,
                                right: 80,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    point.photosMain.length ?? 0,
                                    (index) => AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      width: currentPage == index ? 12 : 8,
                                      height: currentPage == index ? 12 : 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: currentPage == index
                                            ? Colors.black
                                            : Colors.grey.shade400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Container(
                              transform: Matrix4.translationValues(0,
                                  -MediaQuery.sizeOf(context).height * 0.01, 0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(25),
                                  topRight: Radius.circular(25),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                    offset: const Offset(0, -4),
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    // Прижимает содержимое к левому краю
                                    children: [
                                      const Text(
                                        "Название",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                        ),
                                      ),
                                      Text(
                                        point.name.isNotEmpty
                                            ? point.name
                                            : 'Название отсутствует',
                                        style: const TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        "Описание",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                        ),
                                      ),
                                      Text(
                                        point.description.isNotEmpty
                                            ? point.description
                                            : 'Описание отсутствует',
                                        style: const TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 7,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ));
    } else {
      return SizedBox.shrink();
    }
  }

  List<Place> points = [];

  @override
  Widget build(BuildContext context) {
    currentDeviceHeight = MediaQuery.sizeOf(context).height;
    currentDeviceWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<PointBloc, PointState>(
            builder: (context, pointState) {
              points = _extractPoints(pointState);
              return Stack(children: [
                _mapBuilder(points),
                _pageViewBulder(pointState),
              ]);
            },
          ),
          _navigationButtons(),
          Positioned(
              left: 0,
              right: 0,
              top: currentDeviceHeight * 0.08,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: const Border(
                          bottom: BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isDropdownExpanded = true;
                                });
                              },
                              child: SizedBox(
                                height: currentDeviceHeight * 0.06,
                                child: _isDropdownExpanded
                                    ? TextField(
                                        controller: _controller,
                                        autofocus: true,
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          height: 1.5,
                                        ),
                                        decoration: const InputDecoration(
                                          hintText: 'Начните вводить имя...',
                                          hintStyle: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.grey,
                                          ),
                                          border: InputBorder.none,
                                        ),
                                        onChanged: (value) {
                                          BlocProvider.of<UserSearchBloc>(
                                                  context)
                                              .add(FetchUsersEvent(value,
                                                  widget.currentUser.jwt));
                                        },
                                      )
                                    : Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          _selectedUser ??
                                              'Начните вводить имя...',
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          if (_selectedUser != null)
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                BlocProvider.of<PointBloc>(context)
                                    .add(OtherUserPointsLoadingEvent('', ''));
                                setState(() {
                                  _selectedUser = null;
                                  _controller.clear();
                                  _isDropdownExpanded = false;
                                });
                              },
                            )
                          else
                            GestureDetector(
                              onTap: _toggleDropdown,
                              child: Icon(
                                _isDropdownExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                size: 24.0,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_isDropdownExpanded)
                      Container(
                        transform: Matrix4.translationValues(
                            0, -MediaQuery.sizeOf(context).height * 0.025, 0),
                        width: double.infinity,
                        height: currentDeviceHeight * 0.93,
                        color: Colors.white,
                        child: Padding(padding: EdgeInsets.only(top: MediaQuery.sizeOf(context).height * 0.02), child:
                        BlocBuilder<UserSearchBloc, UserSearchState>(
                          builder: (context, state) {
                            if (state is UserSearchLoadingState) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (state is UserSearchLoadedState) {
                              if (state.users.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    'Пользователь не найден',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 16),
                                  ),
                                );
                              }
                              return ListView.builder(
                                itemCount: state.users.length,
                                itemBuilder: (context, index) {
                                  final user = state.users[index];
                                  return ListTile(
                                    title: Text(
                                      user,
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    onTap: () {
                                      BlocProvider.of<PointBloc>(context).add(
                                          OtherUserPointsLoadingEvent(
                                              widget.currentUser.jwt, user));
                                      setState(() {
                                        _selectedUser = user;
                                        _isDropdownExpanded = false;
                                      });
                                    },
                                  );
                                },
                              );
                            } else if (state is UserSearchErrorState) {
                              return const Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  'Пользователь не найден',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      )],
                ),
              )),

          // SlidingUpPanel
          BlocBuilder<PointBloc, PointState>(
            builder: (context, pointState) {
              return _slidingUpPanelBuilder(pointState);
            },
          ),
        ],
      ),
    );
  }

/*
  @override
  Widget build(BuildContext context) {
    currentDeviceHeight = MediaQuery.sizeOf(context).height;
    currentDeviceWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<PointBloc, PointState>(
            builder: (context, pointState) {
              final points = _extractPoints(pointState);
              return Stack(children: [
                _mapBuilder(points),
                _pageViewBulder(pointState),
              ]);
            },
          ),
          Stack(
            children: [
              // Белый фон для затемнения при раскрытии списка
              if (_isDropdownExpanded)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isDropdownExpanded = false;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.white, // Полностью белый фон
                  ),
                ),

              Positioned(
                left: 0,
                right: 0,
                top: currentDeviceHeight * 0.05,
                child: GestureDetector(
                  onTap: _toggleDropdown,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: SizedBox(
                                  height: currentDeviceHeight * 0.05,
                                  child: _isDropdownExpanded
                                      ? TextField(
                                    controller: _controller,
                                    autofocus: true,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      height: 1.2, // Высота строки
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Начните вводить имя...',
                                      hintStyle: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.grey,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) {
                                      BlocProvider.of<UserSearchBloc>(context)
                                          .add(FetchUsersEvent(
                                          value, widget.currentUser.jwt));
                                    },
                                  )
                                      : Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      _selectedUser ?? 'Начните вводить имя...',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                )),
                            GestureDetector(
                              onTap: _toggleDropdown,
                              child: Icon(
                                _isDropdownExpanded
                                    ? Icons.keyboard_arrow_up // iOS-стиль вверх
                                    : Icons.keyboard_arrow_down, // iOS-стиль вниз
                                size: 24.0,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isDropdownExpanded)
                        BlocBuilder<UserSearchBloc, UserSearchState>(
                          builder: (context, state) {
                            if (state is UserSearchLoadingState) {
                              return Container(
                                height: currentDeviceHeight,
                                color: Colors.white,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            } else if (state is UserSearchLoadedState) {
                              if (state.users.isEmpty) {
                                return Container(
                                  color: Colors.white,
                                  width: double.infinity,
                                  child: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Text(
                                        'Пользователь не найден',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 16),
                                      )),
                                );
                              }
                              return Container(
                                constraints: BoxConstraints(
                                    maxHeight: currentDeviceHeight * 0.4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: ListView.builder(
                                  itemCount: state.users.length,
                                  itemBuilder: (context, index) {
                                    final user = state.users[index];
                                    return ListTile(
                                      title: Text(
                                        user,
                                        style: const TextStyle(fontSize: 16.0),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          BlocProvider.of<PointBloc>(context)
                                              .add(OtherUserPointsLoadingEvent(
                                              widget.currentUser.jwt, user));
                                          _selectedUser = user;
                                          _isDropdownExpanded = false;
                                        });
                                      },
                                    );
                                  },
                                ),
                              );
                            } else if (state is UserSearchErrorState) {
                              return Container(
                                color: Colors.white,
                                width: double.infinity,
                                child: const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      'Пользователь не найден',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 16),
                                    )),
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          )
,

          Positioned(
            left: 0,
            right: 0,
            top: currentDeviceHeight*0.05,
            child: GestureDetector(
              onTap: _toggleDropdown,
              child:
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: SizedBox(
                          height: currentDeviceHeight * 0.05,
                          child: _isDropdownExpanded
                              ? TextField(
                                  controller: _controller,
                                  autofocus: true,
                                  decoration: const InputDecoration(
                                    hintText: 'Начните вводить имя...',
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    BlocProvider.of<UserSearchBloc>(context)
                                        .add(FetchUsersEvent(
                                            value, widget.currentUser.jwt));
                                  },
                                )
                              : Text(
                                  _selectedUser ?? 'Начните вводить имя...',
                                  style: const TextStyle(fontSize: 16.0),
                                  overflow: TextOverflow.ellipsis,
                                ),
                        )),
                        Icon(
                          _isDropdownExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                        ),
                      ],
                    ),
                  ),
                  if (_isDropdownExpanded)
                    BlocBuilder<UserSearchBloc, UserSearchState>(
                      builder: (context, state) {
                        if (state is UserSearchLoadingState) {
                          return Container(
                            height: currentDeviceHeight,
                            color: Colors.white,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else if (state is UserSearchLoadedState) {
                          if (state.users.isEmpty) {
                            return Container(
                              color: Colors.white,
                              width: double.infinity,
                              child: const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    'Пользователь не найден',
                                    style: TextStyle(
                                        backgroundColor: Colors.white),
                                  )),
                            );
                          }
                          return Container(
                            constraints:
                                BoxConstraints(maxHeight: currentDeviceHeight),
                            color: Colors.white,
                            child: ListView.builder(
                              itemCount: state.users.length,
                              itemBuilder: (context, index) {
                                final user = state.users[index];
                                return ListTile(
                                  title: Text(user),
                                  onTap: () {
                                    setState(() {
                                      BlocProvider.of<PointBloc>(context).add(
                                          OtherUserPointsLoadingEvent(
                                              widget.currentUser.jwt, user));
                                      _selectedUser = user;
                                      _isDropdownExpanded = false;
                                    });
                                  },
                                );
                              },
                            ),
                          );
                        } else if (state is UserSearchErrorState) {
                          return Container(
                            color: Colors.white,
                            width: double.infinity,
                            child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  'Пользователь не найден',
                                  style:
                                      TextStyle(backgroundColor: Colors.white),
                                )),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                ],
              ),
            ),
          ),

          BlocBuilder<PointBloc, PointState>(
            builder: (context, pointState) {
              return _slidingUpPanelBuilder(pointState);
            },
          ),
        ],
      ),
    );
  }*/
}
