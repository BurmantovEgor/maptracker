import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../models/place.dart';

class MapRepository {
  final List<Place> _places = [];

  List<Place> get places => _places;

  void addPlace(Place place) {
    _places.add(place);
  }

  void updatePlace(int index, Place place) {
    _places[index] = place;
  }

  void removePlace(int index) {
    _places.removeAt(index);
  }

  void clearTemporaryPoints() {
    _places.removeWhere((place) => !place.isAdded);
  }
}
