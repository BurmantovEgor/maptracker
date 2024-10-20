import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'dart:developer';

import '../../domain/user.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int counter = 0;
  PanelController controller = new PanelController();
  late final _animatedMapController = AnimatedMapController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeIn,
  );

  User temp = User();

  @override
  void initState() {
    temp.temp = [];
    super.initState();
  }

  List<AnimatedMarker> _markers = [];
  List<AnimatedMarker> finalListMark = [];

  void _addMarker(LatLng point) {
    setState(() {
      _markers.add(
        AnimatedMarker(
          point: point,
          builder: (_, animation) {
            final size = 25.0 * animation.value;
            return GestureDetector(
                onTap: () {
                  controller.open();
                  tempContr.text = temp.name + "123312";
                },
                child: Icon(
                  Icons.location_pin,
                  size: size,
                ));
          },
        ),
      );
    });
  }

  LatLng tempPoint = LatLng(0, 0);
  bool _isPanelOpen = false;
  TextEditingController tempContr = TextEditingController();

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
                child: FlutterMap(
              mapController: _animatedMapController.mapController,
              options: MapOptions(
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                ),
                initialCenter: const LatLng(55.755793, 37.617134),
                initialZoom: 10,
                onTap: (tapPosition, point) {
                  _animatedMapController.centerOnPoint(point);
                  if (!finalListMark.contains(tempPoint)) {
                    setState(() {
                      _markers.remove(tempPoint);
                    });
                  }
                  tempPoint = point;
                  _addMarker(point);
                  controller.open();
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
              onPanelSlide: (double pos) {
                double panelHeight = MediaQuery.sizeOf(context).height * pos;

                double screenHeight = MediaQuery.sizeOf(context).height;

                double offsetFraction = panelHeight / screenHeight;

                double newLatitude = tempPoint.latitude -
                    offsetFraction *
                        180.0 /
                        (256 *
                            (_animatedMapController.mapController.camera.zoom
                                .toInt()));
                _animatedMapController
                    .centerOnPoint(LatLng(newLatitude, tempPoint.longitude));
              },
              onPanelOpened: () {
                _isPanelOpen = true;
              },
              onPanelClosed: () {
                _isPanelOpen = false;
              },
              maxHeight: MediaQuery.sizeOf(context).height * 0.4,
              minHeight: 0,
              controller: controller,
              defaultPanelState: PanelState.CLOSED,
              backdropEnabled: false,
              panel: Container(
                  child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: tempContr,
                      onChanged: (String a) {
                        temp.name = a;
                      },
                      decoration: InputDecoration(
                          fillColor: Colors.green,
                          border: OutlineInputBorder(
                              borderSide: BorderSide(width: 10),
                              borderRadius: BorderRadius.circular(10))),
                    ),
                    TextField(
                      onChanged: (String a) {
                        temp.descr = a;
                      },
                      decoration: InputDecoration(
                          fillColor: Colors.green,
                          border: OutlineInputBorder(
                              borderSide: BorderSide(width: 10),
                              borderRadius: BorderRadius.circular(10))),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            temp.temp?.add(
                              AnimatedMarker(
                                point: tempPoint,
                                builder: (_, animation) {
                                  final size = 25.0 * animation.value;
                                  return Icon(
                                    Icons.location_pin,
                                    size: size,
                                  );
                                },
                              ),
                            );
                            finalListMark.add(
                              AnimatedMarker(
                                point: tempPoint,
                                builder: (_, animation) {
                                  final size = 25.0 * animation.value;
                                  return Icon(
                                    Icons.location_pin,
                                    size: size,
                                  );
                                },
                              ),
                            );
                          });
                        },
                        child: Text("data"))
                  ],
                ),
              )),
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
