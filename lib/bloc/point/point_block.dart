import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_tracker/bloc/point/point_event.dart';
import 'package:map_tracker/bloc/point/point_state.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../data/models/place.dart';

class PointBloc extends Bloc<PointEvent, PointState> {
  final List<place> _points = [];

  PointBloc() : super(PointsInitialState()) {
    on<LoadPointsEvent>((event, emit) {
      emit(PointsLoadedState(points: _points));
    });
    void UnselectPoint(List<place> points) {
      for (int i = 0; i < points.length; i++) {
        points[i].isSelected = false;
      }
    }

    on<UpdateTemporaryPointNameEvent>((event, emit) {
      final currentState = state as PointsLoadedState;

      if (currentState.temporaryPoint != null &&
          (currentState.temporaryPoint!.name != event.name ||
              currentState.temporaryPoint!.description != event.description)) {
        final updatedTemporaryPoint = currentState.temporaryPoint!
            .copyWith(name: event.name, description: event.description);
        emit(PointsLoadedState(
          points: currentState.points,
          selectedIndex: currentState.selectedIndex,
          temporaryPoint: updatedTemporaryPoint,
        ));
      }
    });

    on<RemovePointEvent>((event, emit) {
      final currentState = state as PointsLoadedState;
      currentState.points.removeAt(currentState.selectedIndex);

      emit(PointsLoadedState(
        points: currentState.points,
        selectedIndex: currentState.selectedIndex == 0
            ? 0
            : currentState.selectedIndex - 1,
      ));
    });
  /*  on<CreateTemporaryPointEvent>((event, emit) {
      final currentState = state as PointsLoadedState;
      UnselectPoint(currentState.points);
      emit(PointsLoadedState(
        points: currentState.points,
        selectedIndex: currentState.selectedIndex,
        temporaryPoint: place(
          placeLocation:
              Point(latitude: event.latitude, longitude: event.longitude),
          name: '',
          description: '',
          isPointTemporay: true,
          isSelected: false,
          photos: null,
        ),
      ));
    });
*/

    on<CreateTemporaryPointEvent>((event, emit) {
      final currentState = state as PointsLoadedState;
      UnselectPoint(currentState.points);

      // Создаем временную точку
      final temporaryPoint = place(
        placeLocation: Point(latitude: event.latitude, longitude: event.longitude),
        name: '',
        description: '',
        isPointTemporay: true,
        isSelected: false,
        photos: null,
      );

      // Эмитим новое состояние с временной точкой
      emit(PointsLoadedState(
        points: currentState.points,
        selectedIndex: currentState.selectedIndex,
        temporaryPoint: temporaryPoint,
      ));
    });

    on<UpdatePointEvent>((event, emit) {
      final currentState = state as PointsLoadedState;

      if (currentState.points.contains(event.updatedPoint)) return;

      final updatedPoints = currentState.points.map((point) {
        if (point.placeLocation.latitude ==
                event.updatedPoint.placeLocation.latitude &&
            point.placeLocation.longitude ==
                event.updatedPoint.placeLocation.longitude) {
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
        final newPoint = currentState.temporaryPoint!
            .copyWith(isPointTemporay: false, isSelected: true);
        final updatedPoints = List<place>.from(currentState.points)
          ..add(newPoint);
        emit(PointsLoadedState(
          points: updatedPoints,
          selectedIndex: updatedPoints.length - 1,
          selectedPoint: newPoint,
        ));
      }
    });
    on<CancelTemporaryPointEvent>((event, emit) {
      final currentState = state as PointsLoadedState;
      emit(PointsLoadedState(
        points: currentState.points,
        selectedIndex: currentState.selectedIndex,
      ));
    });

    on<SelectPointEvent>((event, emit) {
      final currentState = state as PointsLoadedState;
      for (int i = 0; i < currentState.points.length; i++) {
        currentState.points[i].isSelected = false;
      }
      currentState.points[event.index].isSelected = true;
      emit(PointsLoadedState(
        points: currentState.points,
        selectedIndex: event.index,
        selectedPoint: currentState.points[event.index],
      ));
    });
  }
}
