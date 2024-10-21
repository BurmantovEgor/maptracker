import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_tracker/presentation/widgets/sliding_up_panel.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:map_tracker/domain/point.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late YandexMapController _mapController;

  bool _isSelected = false;
  List<MapObject<dynamic>> mapObjects = [
    PlacemarkMapObject(
      mapId: MapObjectId('placemark_1'),
      point: Point(
        latitude: 51.507351,
        longitude: -0.127696,
      ),
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: BitmapDescriptor.fromAssetImage('assets/icons/point.png'),
          // Путь к вашей иконке
          scale: 0.1, // Уменьшите или увеличьте масштаб для отображения
        ),
      ),
    )
  ];

  List<PointDTO> _pointList = [
    PointDTO("Point 1", "Description 1", LatLng(51.507351, -0.127696)),
    PointDTO("Point 2", "Description 2", LatLng(41.887064, 12.504809)),
  ];

  List<PlacemarkMapObject> _getPlacemarkObjects() {
    return _pointList
        .asMap()
        .map(
          (index, point) => MapEntry(
            index,
            PlacemarkMapObject(
              onTap: (o, p) {
                setState(() {
                  _isSelected = true;
                });
              },
              mapId: MapObjectId('placemark_$index'),
              opacity: 1,
              point: Point(
                latitude: point.marker.latitude,
                longitude: point.marker.longitude,
              ),
              icon: _isSelected
                  ? PlacemarkIcon.single(
                      PlacemarkIconStyle(
                        image: BitmapDescriptor.fromAssetImage(
                            'assets/icons/point.png'), // Путь к вашей иконке
                        scale:
                            0.5, // Уменьшите или увеличьте масштаб для отображения
                      ),
                    )
                  : PlacemarkIcon.single(
                      PlacemarkIconStyle(
                        image: BitmapDescriptor.fromAssetImage(
                            'assets/icons/point.png'), // Путь к вашей иконке
                        scale:
                            0.1, // Уменьшите или увеличьте масштаб для отображения
                      ),
                    ),
            ),
          ),
        )
        .values
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('jfdj')),
        body: Stack(children: [
          YandexMap(
            onMapTap: (Point p) {
              setState(() {
                _pointList.add(PointDTO("", "description", LatLng(p.latitude,p.longitude)));
              });
              _mapController.moveCamera(
                animation: const MapAnimation(
                    type: MapAnimationType.smooth, duration: 0.5),
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: Point(
                      latitude: p.latitude, // Позиция камеры на первый маркер
                      longitude: p.longitude,
                    ),
                    zoom: 10,
                  ),
                ),
              );
            },

            onMapCreated: (controller) async {
              _mapController = controller;
              await _mapController.moveCamera(
                animation: const MapAnimation(
                    type: MapAnimationType.smooth, duration: 5),
                CameraUpdate.newCameraPosition(
                  const CameraPosition(
                    target: Point(
                      latitude: 41.887064, // Позиция камеры на первый маркер
                      longitude:  12.504809,
                    ),
                    zoom: 10,
                  ),
                ),
              );

              // После создания карты, обновите объекты на карте
              setState(() {});
            },
            mapObjects: _getPlacemarkObjects(), // Отображение объектов карты
          ),
          /* Positioned(
          left: 0,
            top: 0,
            child: Image.asset('assets/icons/point.png'))*/
        ]));
  }
}
