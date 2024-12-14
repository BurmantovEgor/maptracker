import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_tracker/bloc/point/point_event.dart';
import 'package:map_tracker/bloc/point/point_state.dart';

import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../data/DTO/placeDTO.dart';
import '../../data/mappers/place_mapper.dart';
import '../../data/models/place.dart';
import '../../service/palce_service.dart';

class PointBloc extends Bloc<PointEvent, PointState> {
  List<PlaceDTO> _points = [];
  final PlaceService apiService;

  PointBloc(this.apiService) : super(PointsInitialState()) {


    on<LoadPointsEvent>((event, emit) async {
      if (event.jwt.trim().isNotEmpty) {
        _points = await apiService.getPlaces(event.jwt);
        print('userPoints: ${_points.length}');
        final mappedPoints = PlaceMapper.fromPlaceRepoListToPlaceList(_points);
        print('mappedPoints: ${mappedPoints.length}');
        emit(PointsLoadedState(points: mappedPoints));
      } else {
        emit(PointsLoadedState(points: []));
      }
    });

    void UnselectPoint(List<Place> points) {
      for (int i = 0; i < points.length; i++) {
        points[i].isSelected = false;
      }
    }

    on<OtherUserPointsLoadingEvent>((event, emit) async {
      if (event.jwt.trim().isNotEmpty) {
        print('testGetUser');
        _points = await apiService.getUserPlaces(event.userId,event.jwt);
        print('userPoints: ${_points.length}');
        final mappedPoints = PlaceMapper.fromPlaceRepoListToPlaceList(_points);
        print('mappedPoints: ${mappedPoints.length}');
        emit(OtherUserPointsLoadedState(points: mappedPoints));
      } else {
        emit(OtherUserPointsLoadedState(points: []));
      }
    });

    on<UpdateTemporaryPointNameEvent>((event, emit) {
      final currentState = state as PointsLoadedState;
      if (currentState.temporaryPoint != null &&
          (currentState.temporaryPoint!.name != event.name ||
              currentState.temporaryPoint!.description != event.description)) {
        final updatedTemporaryPoint = currentState.temporaryPoint!.copyWith(
            name: event.name, description: event.description, photosMain: []);


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

    on<CreateTemporaryPointEvent>((event, emit) {
      UnselectPoint(state is PointsLoadedState
          ? (state as PointsLoadedState).points
          : []);
      final temporaryPoint = Place(
          id: "",
          placeLocation:
              Point(latitude: event.latitude, longitude: event.longitude),
          name: '',
          description: '',
          isPointTemporay: true,
          isSelected: false,
          photosMain: []);
      print('CreateTemporaryPointEvent');
      emit(PointsLoadedState(
        points: state is PointsLoadedState
            ? (state as PointsLoadedState).points
            : [],
        selectedIndex: state is PointsLoadedState
            ? (state as PointsLoadedState).selectedIndex
            : -1,
        temporaryPoint: temporaryPoint,
      ));
    });

    on<UpdatePointEvent>((event, emit)  async {
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
      await apiService.updatePlace(event.updatedPoint, event.currentUser.jwt);

      emit(PointsLoadedState(
        points: updatedPoints,
        selectedIndex: currentState.selectedIndex,
        selectedPoint: event.updatedPoint,
      ));
    });

    on<SaveTemporaryPointEvent>((event, emit) async {
      final currentState = state as PointsLoadedState;
      final newPoint = event.newPoint.copyWith(
          isPointTemporay: false,
          isSelected: true,
          photosMain: currentState.temporaryPoint!.photosMain);
      final updatedPoints = List<Place>.from(currentState.points)
        ..add(newPoint);


      final placeDTO = PlaceMapper.fromPlaceToPlaceCreateDTO(newPoint);
      await apiService.addPlace(placeDTO, event.currentUser.jwt);

      emit(PointsLoadedState(
        points: updatedPoints,
        selectedIndex: updatedPoints.length - 1,
        selectedPoint: newPoint,
      ));
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
