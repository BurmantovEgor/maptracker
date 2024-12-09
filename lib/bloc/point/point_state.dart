import '../data/models/Location.dart';

abstract class PointState {}

class PointsInitialState extends PointState {}

class PointsLoadedState extends PointState {
  final List<CustomPoint> points;
  final int selectedIndex;
  final CustomPoint? selectedPoint;
  final CustomPoint? temporaryPoint;

  PointsLoadedState({
    required this.points,
    this.selectedIndex = 0,
    this.selectedPoint,
    this.temporaryPoint,
  });
}
