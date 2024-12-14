import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_tracker/service/palce_service.dart';
import 'package:map_tracker/service/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user.dart';
import 'user_event.dart';
import 'user_state.dart';
import 'package:dio/dio.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserService apiService;

  UserBloc(this.apiService) : super(UserInitialState()) {
    on<RegisterUserEvent>(_onRegisterUser);
    on<LoginUserEvent>(_onLoginUser);
    /* on<LogoutUserEvent>(_onLogoutUser);*/
  }

  Future<void> _onRegisterUser(
      RegisterUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoadingState());
    try {
      final user = await apiService.registerUser(event);
      if (user.id != -1) {
        emit(UserLoadedState(user: user));
      } else {
        emit(UserErrorState(error: "Registration failed"));
        emit(UserInitialState());
      }
    } catch (e) {
      emit(UserErrorState(error: e.toString()));
      emit(UserInitialState());
    }
  }

  Future<void> _onLoginUser(
      LoginUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoadingState());
    try {
      final user = await apiService.loginUser(event);

      if (user.id != -1) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', user.email);
        await prefs.setString('password', event.password);
        emit(UserLoadedState(user: user));
      } else {
        emit(UserErrorState(error: ""));
        emit(UserInitialState());
      }
    } catch (e) {
      emit(UserErrorState(error: e.toString()));
      emit(UserInitialState());
    }
  }

/*Future<void> _onLogoutUser(LogoutUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoggedOutState());
  }*/
}
