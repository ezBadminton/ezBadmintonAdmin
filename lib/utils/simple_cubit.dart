import 'package:flutter_bloc/flutter_bloc.dart';

/// Very simple [Cubit] that just emits objects of [T] on demand.
class SimpleCubit<T> extends Cubit<T> {
  SimpleCubit(super.initialState);

  /// Emits the [newState]
  void changeState(T newState) {
    super.emit(newState);
  }
}
