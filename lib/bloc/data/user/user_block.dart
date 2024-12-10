import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_tracker/bloc/data/user/user_event.dart';
import 'package:map_tracker/bloc/data/user/user_state.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc() : super(LocationInitial()) {
    // Обработчик события LoadUserLocationEvent
    on<LoadUserLocationEvent>(_onLoadUserLocation);
  }

  Future<void> _onLoadUserLocation(
    LoadUserLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading()); // Состояние загрузки
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(LocationError('Location services are disabled.'));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(LocationError('Location permissions are denied.'));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(LocationError(
            'Location permissions are permanently denied, we cannot request permissions.'));
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      emit(LocationLoaded(Point(
        latitude: position.latitude,
        longitude: position.longitude,
      ))); // Состояние с координатами пользователя
    } catch (e) {
      emit(LocationError('Failed to get location: $e'));
    }
  }
}
