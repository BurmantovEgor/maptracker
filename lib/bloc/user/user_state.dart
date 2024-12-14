import 'package:equatable/equatable.dart';
import '../../data/models/user.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitialState extends UserState {}

class UserLoadingState extends UserState {}

class UserLoadedState extends UserState {
  final User user;

  UserLoadedState({required this.user});

  @override
  List<Object?> get props => [user];
}

class UserErrorState extends UserState {
  final String error;

  UserErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}

class UserLoggedOutState extends UserState {}
