import 'package:map_tracker/data/dto/photoUpdateDTO.dart';

import '../models/photo.dart';
import '../models/place.dart';

class PlaceUpdateDTO {
  final String id;
  final String name;
  final String description;
  final bool isActive;
  final double latitude;
  final double longitude;
  final List<PhotoUpdateDTO> photos;

  PlaceUpdateDTO({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.latitude,
    required this.longitude,
    required this.photos,
  });

  factory PlaceUpdateDTO.fromPointAndPhotos(Place point) {
    return PlaceUpdateDTO(
      id: point.id,
      name: point.name,
      description: point.description,
      isActive: true,
      latitude: point.placeLocation.latitude,
      longitude: point.placeLocation.longitude,
      photos:  point.photosMain.map((photo) => PhotoUpdateDTO.fromPhoto(photo)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isActive': isActive,
      'latitude': latitude,
      'longitude': longitude,
      'photos': photos.map((photoDTO) => photoDTO.toMap()).toList(),
    };
  }
}
