import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../data/models/place.dart';
import '../../data/models/user.dart';

abstract class PointEvent {}

class LoadPointsEvent extends PointEvent {
  final String jwt;

  LoadPointsEvent(this.jwt);
}

class OtherUserPointsLoadingEvent extends PointEvent {
  final String jwt;
  final String userId;

  OtherUserPointsLoadingEvent(this.jwt, this.userId);
}

class CreateTemporaryPointEvent extends PointEvent {
  final double latitude;
  final double longitude;

  CreateTemporaryPointEvent(this.latitude, this.longitude);
}

class CancelTemporaryPointEvent extends PointEvent {}

class RemovePointEvent extends PointEvent {
  final int selectedIndex;
  final String jwt;
  RemovePointEvent({required this.selectedIndex, required this.jwt});

}

class UpdatePointEvent extends PointEvent {
  final Place updatedPoint;
  final User currentUser;
  UpdatePointEvent(this.updatedPoint, this.currentUser);
}

class SaveTemporaryPointEvent extends PointEvent {
  final Place newPoint;
  final User currentUser;

  SaveTemporaryPointEvent(this.newPoint, this.currentUser);
}

class SelectPointEvent extends PointEvent {
  final int index;
  SelectPointEvent(this.index);
}

class SelectPointOtherUserEvent extends PointEvent {
  final int index;
  SelectPointOtherUserEvent(this.index);
}


class UpdateTemporaryPointNameEvent extends PointEvent {
  final String name;
  final String description;

  UpdateTemporaryPointNameEvent(this.name, this.description);
}
