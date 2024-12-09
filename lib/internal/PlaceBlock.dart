import 'package:flutter_bloc/flutter_bloc.dart';

class PlaceBloc extends Bloc<PlaceEvent, PlaceState>{
  PlaceBloc(super.initialState);
}


abstract class PlaceEvent{
  const PlaceEvent();
}
class RemoveElementEvent extends PlaceEvent{}


abstract class PlaceState{
  const PlaceState();
}
class RemoveInital extends PlaceState{}
