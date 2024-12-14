abstract class UserSearchEvent {}

class FetchUsersEvent extends UserSearchEvent {
  final String query;
  final String jwt;

  FetchUsersEvent(this.query, this.jwt);
}
