import '../../data/models/place.dart';

abstract class PointState {}

class PointsInitialState extends PointState {}

class PointsLoadingState extends PointState {}

class PointsLoadedState extends PointState {
  final List<Place> points;
  final int selectedIndex;
  final Place? selectedPoint;
  final Place? temporaryPoint;

  PointsLoadedState({
    required this.points,
    this.selectedIndex = 0,
    this.selectedPoint,
    this.temporaryPoint,
  });
}

class OtherUserPointsLoadedState extends PointState {
  final List<Place> points;
  final int selectedIndex;

  OtherUserPointsLoadedState({
    required this.points,
    this.selectedIndex = 0,
  });
}
