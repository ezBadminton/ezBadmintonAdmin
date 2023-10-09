import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'interactive_view_blocker_state.dart';

class InteractiveViewBlockerCubit extends Cubit<InteractiveViewBlockerState> {
  InteractiveViewBlockerCubit() : super(const InteractiveViewBlockerState());

  void addZoomingBlock() {
    emit(state.copyWith(
      zoomingBlocks: state.zoomingBlocks + 1,
    ));
  }

  void removeZoomingBlock() {
    int newBlocks = max(0, state.zoomingBlocks - 1);
    emit(state.copyWith(zoomingBlocks: newBlocks));
  }

  void addEdgePanningBlock() {
    emit(state.copyWith(
      edgePanningBlocks: state.edgePanningBlocks + 1,
    ));
  }

  void removeEdgePanningBlock() {
    int newBlocks = max(0, state.edgePanningBlocks - 1);
    emit(state.copyWith(edgePanningBlocks: newBlocks));
  }
}
