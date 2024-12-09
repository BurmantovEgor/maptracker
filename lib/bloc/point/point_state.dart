import '../data/models/place.dart';

abstract class PointState {}

class PointsInitialState extends PointState {}

class PointsLoadedState extends PointState {
  final List<place> points;
  final int selectedIndex;
  final place? selectedPoint;
  final place? temporaryPoint;

  PointsLoadedState({
    required this.points,
    this.selectedIndex = 0,
    this.selectedPoint,
    this.temporaryPoint,
  });
}
