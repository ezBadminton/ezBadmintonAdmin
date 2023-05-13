import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'popover_menu_state.dart';

class PopoverMenuCubit extends Cubit<PopoverMenuState> {
  PopoverMenuCubit() : super(const PopoverMenuState());

  void setMenu(List<OverlayEntry> menu) {
    for (OverlayEntry menuEntry in state.menu) {
      menuEntry.remove();
    }
    PopoverMenuState newState = state.copyWith(
      opacity: PopoverMenuState.initialOpacity,
      scale: PopoverMenuState.initialScale,
      menu: menu,
    );
    emit(newState);
  }

  void setOpacity(double opacity) {
    PopoverMenuState newState = state.copyWith(opacity: opacity);
    emit(newState);
  }

  void setScale(double scale) {
    PopoverMenuState newState = state.copyWith(scale: scale);
    emit(newState);
  }
}
