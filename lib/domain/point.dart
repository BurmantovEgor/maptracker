import 'package:latlong2/latlong.dart';

class PointDTO {

  String name = "";
  String description = "";
  LatLng marker;

  PointDTO(this.name, this.description, this.marker);

}