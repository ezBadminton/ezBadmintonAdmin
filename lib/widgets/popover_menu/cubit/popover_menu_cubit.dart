import 'package:bloc/bloc.dart';
import 'package:ez_badminton_admin_app/widgets/popover_menu/controller/popover_menu_controller.dart';
import 'package:flutter/material.dart';

part 'popover_menu_state.dart';

class PopoverMenuCubit extends Cubit<PopoverMenuState> {
  PopoverMenuCubit({
    required Widget menuContent,
    required this.menuBuilder,
    required this.layerLink,
    this.controller,
  }) : super(PopoverMenuState(menuContent: menuContent)) {
    if (controller != null) {
      controller!.addListener(_controllerChanged);
      _controllerChanged();
    }
  }
  final List<OverlayEntry> Function(Widget, PopoverMenuCubit) menuBuilder;

  final LayerLink layerLink;

  final PopoverMenuController? controller;

  void openMenu() {
    emit(state.copyWith(menu: menuBuilder(state.menuContent, this)));
  }

  void closeMenu() {
    emit(state.copyWith(menu: []));
  }

  void menuContentChanged(Widget menuContent) {
    if (state.menuContent != menuContent) {
      emit(state.copyWith(menuContent: menuContent));
      if (state.isMenuOpen) {
        closeMenu();
        openMenu();
      }
    }
  }

  void _controllerChanged() {
    if (controller!.isMenuOpen != state.isMenuOpen) {
      if (controller!.isMenuOpen) {
        openMenu();
      } else {
        closeMenu();
      }
    }
  }

  @override
  Future<void> close() {
    controller?.removeListener(_controllerChanged);
    return super.close();
  }
}
