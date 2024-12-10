import 'package:yandex_mapkit/yandex_mapkit.dart';

abstract class LocationState {}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final Point userLocation;

  LocationLoaded(this.userLocation);
}

class LocationError extends LocationState {
  final String message;

  LocationError(this.message);
}
