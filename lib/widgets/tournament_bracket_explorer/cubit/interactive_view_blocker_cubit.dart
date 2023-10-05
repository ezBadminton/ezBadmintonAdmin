import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'interactive_view_blocker_state.dart';

class InteractiveViewBlockerCubit extends Cubit<InteractiveViewBlockerState> {
  InteractiveViewBlockerCubit() : super(const InteractiveViewBlockerState());

  void addBlock() {
    emit(InteractiveViewBlockerState(blocks: state.blocks + 1));
  }

  void removeBlock() {
    int newBlocks = max(0, state.blocks - 1);
    emit(InteractiveViewBlockerState(blocks: newBlocks));
  }
}
