abstract class UserSearchState {}

class UserSearchInitialState extends UserSearchState {}

class UserSearchLoadingState extends UserSearchState {}

class UserSearchLoadedState extends UserSearchState {
  final List<String> users;

  UserSearchLoadedState(this.users);
}

class UserSearchErrorState extends UserSearchState {
  final String message;

  UserSearchErrorState(this.message);
}
