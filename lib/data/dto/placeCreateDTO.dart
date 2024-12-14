import 'dart:io';

import 'package:map_tracker/data/dto/photoCreateDTO.dart';

class PlaceCreateDTO {
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final List<PhotoCreateDTO> photos;

  PlaceCreateDTO({
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.photos,
  });
}
