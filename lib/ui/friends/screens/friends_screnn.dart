import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_tracker/bloc/point/point_event.dart';
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
  late UserSearchBloc _userSearchBloc;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isSearchVisible = false;
  bool _isDropdownExpanded = false;
  String? _selectedUser;

  void _toggleSearchVisibility() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (_isSearchVisible) {
        _isDropdownExpanded = true;
        _controller.clear();
        _userSearchBloc.add(FetchUsersEvent(''));
        Future.delayed(const Duration(milliseconds: 300), () {
          _focusNode.requestFocus();
        });
      } else {
        _isDropdownExpanded = false;
        _focusNode.unfocus();
      }
    });
  }


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownExpanded = !_isDropdownExpanded;
      if (_isDropdownExpanded) {
        _controller.clear();
        BlocProvider.of<UserSearchBloc>(context).add(FetchUsersEvent(''));
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
    print('userPoints Lent: ${userPoints.length}');
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
            print('userPoints Lent2222: ${userPoints.length}');
            final point = userPoints[index];
            return GestureDetector(
              onTap: () {
                _moveCameraToPoint(_mapController,
                    userPoints[index].placeLocation, false, null);
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
                                overflow: TextOverflow
                                    .visible,
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
                                overflow: TextOverflow
                                    .ellipsis,
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
            BlocProvider.of<PointBloc>(context).add(SelectPointEvent(index));
          },
        ),
      ),
    );
  }

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

  Widget _buildSlidingPanel(OtherUserPointsLoadedState state) {
    final point = state.points[state.selectedIndex];
    final nameController = TextEditingController(text: point.name ?? '');
    final descriptionController =
        TextEditingController(text: point.description ?? '');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/settings');
          } else if (index == 0) {
            Navigator.pushNamed(context, '/map');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Карта',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Поиск людей',
          ),
        ],
      ),
      appBar: AppBar(
        title: const Text('Поиск людей'),
        leading: BackButton(
          onPressed: () {
            Navigator.pushNamed(context, '/map');
          },
        ),
      ),
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
          Positioned(
            top: 16.0,
            left: 16.0,
            right: 16.0,
            child: GestureDetector(
              onTap: _toggleDropdown,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _isDropdownExpanded
                              ? TextField(
                                  controller: _controller,
                                  autofocus: true,
                                  decoration: const InputDecoration(
                                    hintText: 'Search for a user...',
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    BlocProvider.of<UserSearchBloc>(context)
                                        .add(FetchUsersEvent(value));
                                  },
                                )
                              : Text(
                                  _selectedUser ?? 'Select a user',
                                  style: const TextStyle(fontSize: 16.0),
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
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
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else if (state is UserSearchLoadedState) {
                          if (state.users.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('No users found.'),
                            );
                          }
                          return Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            margin: const EdgeInsets.only(top: 8.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white,
                            ),
                            child: ListView.builder(
                              itemCount: state.users.length,
                              itemBuilder: (context, index) {
                                final user = state.users[index];
                                return ListTile(
                                  title: Text(user),
                                  onTap: () {
                                    setState(() {
                                      print('tet');
                                      print(user);

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
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              state.message,
                              style: const TextStyle(color: Colors.red),
                            ),
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
              final points = _extractPoints(pointState);
              return    _slidingUpPanelBuilder(pointState);

            },
          ),
        ],
      ),
    );
  }
}
