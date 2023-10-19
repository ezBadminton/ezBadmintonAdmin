import 'package:flutter_bloc/flutter_bloc.dart';

class CallOutScriptCubit extends Cubit<int> {
  CallOutScriptCubit() : super(0);

  void goForward() {
    emit(state + 1);
  }
}
