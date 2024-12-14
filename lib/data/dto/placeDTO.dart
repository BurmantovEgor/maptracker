
import 'package:map_tracker/data/models/photo.dart';

class PlaceDTO {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final List<Photo> photos;

  PlaceDTO({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.photos,
  });

  factory PlaceDTO.fromJson(Map<String, dynamic> json) {
    return PlaceDTO(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      photos: json['photos'] != null
          ? List<Photo>.from(
              json['photos'].map((photoJson) => Photo.fromJson(photoJson)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'photos': photos,
    };
  }
}
