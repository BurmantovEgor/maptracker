import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_tracker/bloc/user/userSearch_event.dart';
import 'package:map_tracker/bloc/user/userSearch_state.dart';
import 'package:map_tracker/service/user_service.dart';

class UserSearchBloc extends Bloc<UserSearchEvent, UserSearchState> {
  final UserService service;

  UserSearchBloc(this.service) : super(UserSearchInitialState()) {
    on<FetchUsersEvent>(_onFetchUsers);
  }
  Future<void> _onFetchUsers(
      FetchUsersEvent event, Emitter<UserSearchState> emit) async {
    emit(UserSearchLoadingState());
    try {
      final List<String> results = await service.searchUser(event);
      print('кол-во людей: ${results.length}');
      emit(UserSearchLoadedState(results));

    } catch (e) {
      emit(UserSearchErrorState('Error: $e'));
    }
  }
}
