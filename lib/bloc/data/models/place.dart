import 'package:yandex_mapkit/yandex_mapkit.dart';

class place {
  final Point placeLocation;
  String name;
  String description;
  final List<String>? photos; // Список URL фотографий
  final bool isPointTemporay;
  bool isSelected;

  place(
      {
        required this.photos,
         required this.placeLocation,
      required this.name,
      required this.description,
      required this.isPointTemporay,
      required this.isSelected});

  place copyWith({
    List<String>? photos,
    bool? isSelected,
    Point? placeLocation,
    String? name,
    String? description,
    bool? isPointTemporay,
  }) {
    return place(
      photos: photos?? this.photos,
      isSelected: isSelected ?? this.isSelected,
      placeLocation: placeLocation ?? this.placeLocation,
      name: name ?? this.name,
      description: description ?? this.description,
      isPointTemporay: isPointTemporay ?? this.isPointTemporay,
    );
  }
}
