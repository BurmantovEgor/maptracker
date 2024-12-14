abstract class UserSearchEvent {}

class FetchUsersEvent extends UserSearchEvent {
  final String query;

  FetchUsersEvent(this.query);
}
