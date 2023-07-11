import 'package:flutter_bloc/flutter_bloc.dart';

class MouseHoverCubit extends Cubit<bool> {
  MouseHoverCubit() : super(false);

  void mouseEntered() {
    emit(true);
  }

  void mouseExited() {
    emit(false);
  }
}
