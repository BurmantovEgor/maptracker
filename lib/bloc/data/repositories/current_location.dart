// lib/data/repositories/map_repository.dart

import '../models/Location.dart';

class MapRepository {
  Future<Location> getInitialLocation() async {
    // Возвращаем координаты города Пермь
    return Location(latitude: 58.0105, longitude: 56.2294);
  }
}
