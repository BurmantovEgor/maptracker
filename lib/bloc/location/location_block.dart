
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';


import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  Timer? _locationUpdateTimer;

  LocationBloc() : super(LocationInitial()) {
    on<LoadUserLocationEvent>(_onLoadUserLocation);
    on<UpdateUserLocationEvent>(_onUpdateUserLocation);
    on<SaveCurrentLocationEvent>(_onSaveCurrentLocation);
    on<BackUpdateUserLocationEvent>(_onBackUpdateUserLocation);
    on<StopLocationUpdateTimerEvent>(_onStopLocationUpdateTimer);
  }

  @override
  Future<void> close() {
    _locationUpdateTimer?.cancel();
    return super.close();
  }

  Future<void> _onSaveCurrentLocation(
      SaveCurrentLocationEvent event,
      Emitter<LocationState> emit,
      ) async {
    try {
      if (state is LocationUpdated) {
        emit(LocationIdle((state as LocationUpdated).userLocation));
      }
    } catch (e) {
      emit(LocationError('Failed to save location: $e'));
    }
  }

  Future<void> _onLoadUserLocation(
      LoadUserLocationEvent event,
      Emitter<LocationState> emit,
      ) async {
    print('userLoadLoc 1');

    emit(LocationLoading());
    print('userLoadLoc 2');
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(LocationError('Location services are disabled.'));
        return;
      }
      print('userLoadLoc 3');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(LocationError('Location permissions are denied.'));
          return;
        }
      }
      print('userLoadLoc 4');

      if (permission == LocationPermission.deniedForever) {
        emit(LocationError(
            'Location permissions are permanently denied, we cannot request permissions.'));
        return;
      }
      print('userLoadLoc 5');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('userLoadLoc 6');
      emit(LocationLoaded(Point(
        latitude: position.latitude,
        longitude: position.longitude,
      )));
      print('userLoadLoc 7');

      _startLocationUpdateTimer();

    } catch (e) {
      print('Failed to get location: $e');
      emit(LocationError('Failed to get location: $e'));
    }
  }
  void _startLocationUpdateTimer() {
    _locationUpdateTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      add(BackUpdateUserLocationEvent());
    });

    print('Location update timer started.');

  }
  Future<void> _onStopLocationUpdateTimer(
      StopLocationUpdateTimerEvent event,
      Emitter<LocationState> emit,
      ) async {
    print('Location update timer stopped.');
    _locationUpdateTimer?.cancel();
  }

  Future<void> _onUpdateUserLocation(
      UpdateUserLocationEvent event,
      Emitter<LocationState> emit,
      ) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      emit(LocationUpdated(Point(
        latitude: position.latitude,
        longitude: position.longitude,
      )));

    } catch (e) {
      emit(LocationError('Failed to update location: $e'));
    }
  }

  Future<void> _onBackUpdateUserLocation(
      BackUpdateUserLocationEvent event,
      Emitter<LocationState> emit,
      ) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      emit(BackLocationUpdated(Point(
        latitude: position.latitude,
        longitude: position.longitude,
      )));

    } catch (e) {
      emit(LocationError('Failed to update location: $e'));
    }
  }
}
