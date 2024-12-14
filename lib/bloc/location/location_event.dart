abstract class LocationEvent {}

class LoadUserLocationEvent extends LocationEvent {}

class UpdateUserLocationEvent extends LocationEvent {}
class StopLocationUpdateTimerEvent extends LocationEvent {}
class BackUpdateUserLocationEvent extends LocationEvent {}

class SaveCurrentLocationEvent extends LocationEvent {}
