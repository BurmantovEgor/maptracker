import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class RegisterUserEvent extends UserEvent {
  final String email;
  final String username;
  final String password;

  RegisterUserEvent({required this.email, required this.username, required this.password});
}

class LoginUserEvent extends UserEvent {
  final String email;
  final String password;

  LoginUserEvent({required this.email, required this.password});
}

class LogoutUserEvent extends UserEvent {}
class InitialUserEvent extends UserEvent {}

class LoadUserFromStorageEvent extends UserEvent {}
