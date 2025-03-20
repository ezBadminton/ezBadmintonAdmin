import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'expansion_radio_state.dart';

class ExpansionRadioCubit extends Cubit<ExpansionRadioState> {
  ExpansionRadioCubit()
      : super(ExpansionRadioState(
          controller: null,
          selected: null,
        ));

  void expand(ExpansionTileController controller, Object selected) {
    if (state.controller == controller) {
      return;
    }
    if (state.controller != null && selected != state.selected) {
      state.controller!.collapse();
    }
    emit(ExpansionRadioState(
      controller: controller,
      selected: selected,
    ));
  }

  void collapse() {
    emit(ExpansionRadioState(controller: null, selected: null));
  }

  void dispose(ExpansionTileController controller) {
    if (state.controller == controller) {
      emit(ExpansionRadioState(
        controller: null,
        selected: state.selected,
      ));
    }
  }
}
