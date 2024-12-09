import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../data/models/place.dart';

abstract class PointEvent {}

class LoadPointsEvent extends PointEvent {}

class CreateTemporaryPointEvent extends PointEvent {
  final double latitude;
  final double longitude;
  CreateTemporaryPointEvent(this.latitude, this.longitude);
}
class SaveTemporaryPointEvent extends PointEvent {}
class CancelTemporaryPointEvent extends PointEvent {}
class RemovePointEvent extends PointEvent {}

class UpdatePointEvent extends PointEvent {
  final place updatedPoint;
  UpdatePointEvent(this.updatedPoint);
}

class SelectPointEvent extends PointEvent {
  final int index;
  SelectPointEvent(this.index);
}

class UpdateTemporaryPointNameEvent extends PointEvent {
  final String name;
  final String description;
  UpdateTemporaryPointNameEvent(this.name, this.description);
}

