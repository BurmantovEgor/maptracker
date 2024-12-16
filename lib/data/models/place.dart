import 'package:map_tracker/data/models/photo.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class Place {
  final String id;
  String name;
  String description;
  Point placeLocation;
  List<Photo> photosMain = [];

  final bool isPointTemporay;
  bool isSelected;

  Place(
      {required this.id,
      required this.photosMain,
      required this.placeLocation,
      required this.name,
      required this.description,
      required this.isPointTemporay,
      required this.isSelected});

  Place copyWith(
      {required List<Photo> photosMain,
      bool? isSelected,
      Point? placeLocation,
      String? name,
      String? description,
      bool? isPointTemporay,
      String? id}) {
    return Place(
      id: id ?? this.id,
      photosMain: photosMain,
      isSelected: isSelected ?? this.isSelected,
      placeLocation: placeLocation ?? this.placeLocation,
      name: name ?? this.name,
      description: description ?? this.description,
      isPointTemporay: isPointTemporay ?? this.isPointTemporay,
    );
  }
}
