import 'package:flutter_bloc/flutter_bloc.dart';

class SelectionCubit<T> extends Cubit<T> {
  SelectionCubit(super.initialState);

  void selectionChanged(T selection) {
    emit(selection);
  }
}
