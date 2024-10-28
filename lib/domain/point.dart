import 'dart:ui';

import 'package:latlong2/latlong.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class Place {
  int id = 0; //PK
  int userId = 0; //FK
  int? categoryId; //FK
  String name = "";
  String description = "";
  Point marker;
  List<Image>? photoList;
  bool isSelected = false;
  bool isAdded = false;

  PlacemarkMapObject convertToPlacemarkObject(Place point) {
    return PlacemarkMapObject(
      isDraggable: true,
      mapId: MapObjectId('placemark_$id'),
      opacity: 1,
      point: Point(
        latitude: point.marker.latitude,
        longitude: point.marker.longitude,
      ),
      icon: point.isSelected
          ? PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: BitmapDescriptor.fromAssetImage(
                    'assets/icons/location.png'),
                scale: 0.1,
              ),
            )
          : PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: BitmapDescriptor.fromAssetImage(
                    'assets/icons/location.png'),
                scale: 0.1,
              ),
            ),
    );
  }

  Place(/*this.id, this.userId, this.categoryId,*/ this.name, this.description,
      this.marker/*, this.photoList, this.isSelected*/);
}
