import 'package:yandex_mapkit/yandex_mapkit.dart';

class Place {
  final String name;
  final String description;
  final Point marker;
  final List<String> photoPaths;
  bool isSelected;
  bool isAdded;

  Place({
    required this.name,
    required this.description,
    required this.marker,
    this.photoPaths = const [],
    this.isSelected = false,
    this.isAdded = false,
  });
}
