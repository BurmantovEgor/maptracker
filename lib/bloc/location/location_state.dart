import 'package:yandex_mapkit/yandex_mapkit.dart';

abstract class LocationState {}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final Point userLocation;

  LocationLoaded(this.userLocation);
}

class LocationIdle extends LocationState {
  final Point userLocation;

  LocationIdle(this.userLocation);
}

class LocationUpdated extends LocationState {
  final Point userLocation;

  LocationUpdated(this.userLocation);
}

class BackLocationUpdated extends LocationState {
  final Point userLocation;

  BackLocationUpdated(this.userLocation);
}

class LocationError extends LocationState {
  final String message;

  LocationError(this.message);
}
