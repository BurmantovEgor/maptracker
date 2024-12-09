import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_tracker/bloc/point/point_event.dart';
import 'package:map_tracker/bloc/point/point_state.dart';

import '../data/models/Location.dart';

class PointBloc extends Bloc<PointEvent, PointState> {
  final List<CustomPoint> _points = [];

  PointBloc() : super(PointsInitialState()) {
    on<LoadPointsEvent>((event, emit) {
      emit(PointsLoadedState(points: _points));
    });

    on<UpdateTemporaryPointNameEvent>((event, emit) {
      final currentState = state as PointsLoadedState;

      if (currentState.temporaryPoint != null) {
        // Обновляем только имя временной точки
        final updatedTemporaryPoint = currentState.temporaryPoint!.copyWith(name: event.name);

        emit(PointsLoadedState(
          points: currentState.points,
          selectedIndex: currentState.selectedIndex,
          temporaryPoint: updatedTemporaryPoint,
        ));
      }
    });


    on<CreateTemporaryPointEvent>((event, emit) {
      final currentState = state as PointsLoadedState;

      emit(PointsLoadedState(
        points: currentState.points,
        selectedIndex: currentState.selectedIndex,
        temporaryPoint: CustomPoint(
          latitude: event.latitude,
          longitude: event.longitude,
          name: '',
          isPointTemporay: true,
        ),
      ));
    });

    on<UpdatePointEvent>((event, emit) {
      final currentState = state as PointsLoadedState;
      final updatedPoints = currentState.points.map((point) {
        if (point.latitude == event.updatedPoint.latitude &&
            point.longitude == event.updatedPoint.longitude) {
          return event.updatedPoint;
        }
        return point;
      }).toList();

      emit(PointsLoadedState(
        points: updatedPoints,
        selectedIndex: currentState.selectedIndex,
        selectedPoint: event.updatedPoint,
      ));
    });

    on<SaveTemporaryPointEvent>((event, emit) {
      final currentState = state as PointsLoadedState;
      if (currentState.temporaryPoint != null) {
        final newPoint = currentState.temporaryPoint!.copyWith(
          isPointTemporay: false, // Убираем признак временной точки
        );
        final updatedPoints = List<CustomPoint>.from(currentState.points)..add(newPoint);
        emit(PointsLoadedState(
          points: updatedPoints,
          selectedIndex: updatedPoints.length - 1, // Выбираем новую точку
          selectedPoint: newPoint,
        ));
      }
    });
    on<CancelTemporaryPointEvent>((event, emit) {
      final currentState = state as PointsLoadedState;
      // Удаляем временную точку
      emit(PointsLoadedState(
        points: currentState.points,
        selectedIndex: currentState.selectedIndex,
      ));
    });



    on<SelectPointEvent>((event, emit) {
      final currentState = state as PointsLoadedState;

      emit(PointsLoadedState(
        points: currentState.points,
        selectedIndex: event.index,
        selectedPoint: currentState.points[event.index],
      ));
    });
  }
}
