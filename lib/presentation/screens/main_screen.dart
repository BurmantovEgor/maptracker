/*
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:map_tracker/domain/point.dart';

import '../widgets/CustomTextField.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  PanelController _panelController = new PanelController();
  TextEditingController _nameTextFieldController = TextEditingController();
  TextEditingController _descrTextFieldController = TextEditingController();

  late final _animatedMapController = AnimatedMapController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeIn,
  );

  List<PointDTO> _pointList = [];

  @override
  void initState() {
    super.initState();
  }

  List<AnimatedMarker> _markers = [];

  void _addMarker(LatLng point) {
    setState(() {
      _markers.add(
        AnimatedMarker(
          point: point,
          builder: (_, animation) {
            final size = 25.0 * animation.value;
            return GestureDetector(
                onTap: () {
                  _checkPoint();
                  tempPoint = point;
                  _panelController.open();
                  var _currPoint =
                      _pointList.firstWhere((x) => x.marker == point);
                  _nameTextFieldController.text = _currPoint.name;
                  _descrTextFieldController.text = _currPoint.description;
                },
                child: Icon(
                  Icons.location_pin,
                  size: tempPoint == point ? size * 1.2 : size,
                  color: tempPoint == point ? Colors.red : Colors.black,
                ));
          },
        ),
      );
    });
  }

  void _checkPoint() {
    var index = _pointList.indexWhere((x) => x.marker == tempPoint);
    if (index == -1) {
      setState(() {
        _markers.removeWhere((x) => x.point == tempPoint);
      });
    }
  }

  void SenterOnPointF(double pos) {
    double panelHeight = MediaQuery.sizeOf(context).height * pos;
    double screenHeight = MediaQuery.sizeOf(context).height;
    double offsetFraction = panelHeight / screenHeight;
    double newLatitude = tempPoint.latitude -
        offsetFraction *
            180.0 /
            (256 * (_animatedMapController.mapController.camera.zoom.toInt()));
    _animatedMapController
        .centerOnPoint(LatLng(newLatitude, tempPoint.longitude));
  }

  LatLng tempPoint = LatLng(0, 0);

  _showYesNoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text("Do you want to continue?"),
          actions: <Widget>[
            TextButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Закрываем диалог с результатом false
                //  _panelController.animatePanelToPosition(0.4);

                _panelController.open();
              },
            ),
            TextButton(
              child: Text("Yes"),
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Закрываем диалог с результатом true
              },
            ),
          ],
        );
      },
    ).then((result) {
      // Обрабатываем результат после закрытия диалога
      if (result == true) {
        _checkPoint();
        _nameTextFieldController.text = "";
        _descrTextFieldController.text = "";
      } */
/*else {
        print("User pressed No");
      }*//*

    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios)),
        ),
        body: Stack(
          children: [
            SizedBox(
                height: MediaQuery.sizeOf(context).height,
                child: FlutterMap(
                  mapController: _animatedMapController.mapController,
                  options: MapOptions(
                    interactionOptions: InteractionOptions(
                      flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                    ),
                    initialCenter: const LatLng(55.755793, 37.617134),
                    initialZoom: 10,
                    onTap: (tapPosition, point) {
                      _checkPoint();
                      _nameTextFieldController.text = "";
                      _descrTextFieldController.text = "";
                      _animatedMapController.centerOnPoint(point);
                      tempPoint = point;
                      _addMarker(point);
                      // _panelController.animatePanelToPosition(0.4);

                      _panelController.open();
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    AnimatedMarkerLayer(
                      markers: _markers,
                    ),
                  ],
                )),
            SlidingUpPanel(
              color: Colors.black,
              onPanelSlide: (double pos) {},
              onPanelOpened: () {
                setState(() {});
              },
              onPanelClosed: () {
                setState(() {});
                //SenterOnPointF(0);

                if (!(_nameTextFieldController.text == "") ||
                    !(_descrTextFieldController.text == "")) {
                  //  _showYesNoDialog(context);
                } else {
                  _checkPoint();
                  _nameTextFieldController.text = "";
                  _descrTextFieldController.text = "";
                }
                tempPoint = LatLng(0, 0);
              },
              maxHeight: MediaQuery.sizeOf(context).height * 0.4,
              minHeight: 0,
              controller: _panelController,
              defaultPanelState: PanelState.CLOSED,
              backdropEnabled: false,
              panel: Container(
                child: Column(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            //_panelController.animatePanelToPosition(0);
                            _panelController.close();
                            _pointList.add(PointDTO(
                                _nameTextFieldController.text,
                                _descrTextFieldController.text,
                                LatLng(
                                    tempPoint.latitude, tempPoint.longitude)));
                          });
                        },
                        child: Text("data"))
                  ],
                ),
              ),
              border: Border.all(
                  width: 0, color: Color.fromARGB(255, 240, 240, 240)),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20), topLeft: Radius.circular(20)),
            )
          ],
        ),
      ),
    );
  }
}
*/
