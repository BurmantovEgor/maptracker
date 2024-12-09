import '../data/models/Location.dart';

abstract class PointEvent {}

class LoadPointsEvent extends PointEvent {}

class CreateTemporaryPointEvent extends PointEvent {
  final double latitude;
  final double longitude;
  CreateTemporaryPointEvent(this.latitude, this.longitude);
}

class SaveTemporaryPointEvent extends PointEvent {}

class CancelTemporaryPointEvent extends PointEvent {}

class UpdatePointEvent extends PointEvent {
  final CustomPoint updatedPoint;
  UpdatePointEvent(this.updatedPoint);
}

class SelectPointEvent extends PointEvent {
  final int index;
  SelectPointEvent(this.index);
}

class UpdateTemporaryPointNameEvent extends PointEvent {
  final String name;
  UpdateTemporaryPointNameEvent(this.name);
}

