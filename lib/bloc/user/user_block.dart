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
    on<LogoutUserEvent>(_onLogoutUser);
    on<InitialUserEvent>(_onInditalUser);
  }

  Future<void> _onRegisterUser(RegisterUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoadingState());
    try {
      final user = await apiService.registerUser(event);
      if (user.id != -1) {
        emit(UserRegisteredState(user: user));

      } else {
        emit(UserErrorState(error: "Registration failed"));
        emit(UserInitialState());
      }
    } catch (e) {
      emit(UserErrorState(error: e.toString()));
      emit(UserInitialState());
    }
  }

  Future<void> _onInditalUser(
      InitialUserEvent event,
      Emitter<UserState> emit)
  async {
    emit(UserInitialState());
  }


  Future<void> _onLoginUser(
      LoginUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoadingState());
    try {

      final user = await apiService.loginUser(event);
      print('loggedUser');
      print(user.id);
      print(user.email);
      if (user.id != -1) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', user.email);
        await prefs.setString('password', event.password);
        emit(UserLoadedState(user: user));
      //  emit(UserInitialState());
      } else {
        emit(UserErrorState(error: ""));
        emit(UserInitialState());
      }
    } catch (e) {
      emit(UserErrorState(error: e.toString()));
      emit(UserInitialState());
    }
  }

  Future<void> _onLogoutUser(
      LogoutUserEvent event, Emitter<UserState> emit) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    emit(UserLoggedOutState());
  }
}
