import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:map_tracker/domain/point.dart';
import '../widgets/CustomTextField.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late YandexMapController _mapController;
  final PanelController _panelController = PanelController();
  final TextEditingController _nameTextFieldController =
      TextEditingController();
  final TextEditingController _descrTextFieldController =
      TextEditingController();

  final PageController _pageController = PageController(viewportFraction: 0.9);
  List<Place> _pointList = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void removeSelect() {
    for (Place a in _pointList) {
      a.isSelected = false;
    }
  }

  void SelectPoint(Place place) {
    setState(() {
      removeSelect();
      place.isSelected = true;
    });
  }

  List<PlacemarkMapObject> _convertPlacesToMapObjects() {
    return _pointList
        .asMap()
        .entries
        .map(
          (entry) => PlacemarkMapObject(
            mapId: MapObjectId('placemark_${entry.key}'),
            point: entry.value.marker,
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                anchor: Offset(0.5, 1.0), // Привязка к нижней части иконки
                image: BitmapDescriptor.fromAssetImage(
                    'assets/icons/location.png'),
                scale: entry.value.isSelected ? 0.15 : 0.1,
              ),
            ),
            onTap: (o, p) => setState(() {
              _removeTemporaryPoints();
              _isMarkerTapped = true;
              SelectPoint(entry.value);
              _pageController.animateToPage(entry.key, duration: Duration(milliseconds: 400), curve: Curves.linear);

              _moveCamera(entry.value.marker, 10);


            }),
          ),
        )
        .toList();
  }

  bool _isMarkerTapped = false;
  bool _isMapTapped = false;

  // Adds new point to the map and sets camera position
  void _addNewPoint(Point point) {
    _removeTemporaryPoints();
    if (_isMarkerTapped) {
      _isMarkerTapped = false;
      return;
    }
    _isMapTapped = true;
    final newPlace = Place("", "", point);
    setState(() {
      _pointList.add(newPlace);
      _selectedIndex = _pointList.length - 1;
    });
    SelectPoint(newPlace);
    _pageController.animateToPage(_selectedIndex,
        duration: Duration(milliseconds: 500), curve: Curves.linear);
    _moveCamera(point, 10);
  }

  // Smoothly moves the map camera
  Future<void> _moveCamera(Point point, double zoom) async {
    await _mapController.moveCamera(
      animation: const MapAnimation(
        type: MapAnimationType.linear,
        duration: 0.5,
      ),
      CameraUpdate.newCameraPosition(CameraPosition(target: point, zoom: zoom)),
    );
    if (_isMapTapped) {
      _isMapTapped = false;
    }
  }

  // Clears non-added points from the list
  void _removeTemporaryPoints() {
    _pointList.removeWhere((x) => !x.isAdded);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map Tracker')),
      body: Stack(
        children: [
          // Yandex Map Layer
          Positioned.fill(
            child: YandexMap(
              onMapTap: (point) => _addNewPoint(point),
              onMapCreated: (controller) async {
                _mapController = controller;
                // await _moveCamera(Point(latitude: 41.887064, longitude: 12.504809), 10);
              },
              mapObjects: _convertPlacesToMapObjects(),
            ),
          ),
          // PageView for Place cards
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            height: 130,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pointList.length,
              onPageChanged: (index) {
                _selectedIndex = index;
                _nameTextFieldController.text = _pointList[index].name;
                _descrTextFieldController.text =
                    _pointList[index].description ?? "";
                if (_isMapTapped) {
                  return;
                }
                _moveCamera(_pointList[index].marker, 10);
              },
              itemBuilder: (context, index) {
                final place = _pointList[index];
                return _buildPageItem(place);
              },
            ),
          ),
          // Sliding Panel for Place details
          _buildSlidingPanel(),
        ],
      ),
    );
  }

  // Builds each page item for PageView
  Widget _buildPageItem(Place place) {
    return GestureDetector(
      onTap: () => _panelController.open(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 4,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          place.name.isNotEmpty ? place.name : 'New Point',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // Builds the sliding panel with Place details
  Widget _buildSlidingPanel() {
    return SlidingUpPanel(
      controller: _panelController,
      maxHeight: MediaQuery.of(context).size.height * 0.5,
      minHeight: 0,
      panelBuilder: (controller) => _panelBody(),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(25),
        topRight: Radius.circular(25),
      ),
    );
  }

  // Panel content with TextFields for name and description
  Widget _panelBody() {
    return Column(
      children: [
        CustomTextField(
          nameTextFieldController: _nameTextFieldController,
          isExpanded: false,
          isEnabled: true,
        ),
        CustomTextField(
          nameTextFieldController: _descrTextFieldController,
          isExpanded: true,
          isEnabled: true,
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameTextFieldController.text.isNotEmpty ||
                _descrTextFieldController.text.isNotEmpty) {
              _pointList[_selectedIndex].name = _nameTextFieldController.text;
              _pointList[_selectedIndex].description =
                  _descrTextFieldController.text;
              _pointList[_selectedIndex].isAdded = true;
              _panelController.close();
              setState(() {
                removeSelect();
              });
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
