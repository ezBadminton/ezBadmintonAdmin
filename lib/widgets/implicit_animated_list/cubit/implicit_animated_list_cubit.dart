import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

part 'implicit_animated_list_state.dart';

class ImplicitAnimatedListCubit<T> extends Cubit<ImplicitAnimatedListState<T>> {
  ImplicitAnimatedListCubit() : super(ImplicitAnimatedListState());

  void elementsChanged(List<T> elements) {
    emit(state.copyWith(
      elements: elements,
      previousElements: state.elements,
      removedIndices: _getRemovedIndices(state.elements, elements),
      addedIndices: _getAddedIndices(state.elements, elements),
    ));
  }

  Iterable<int> _getRemovedIndices(List<T> before, List<T> after) {
    return before
        .whereNot((e) => after.contains(e))
        .map((e) => before.indexOf(e));
  }

  Iterable<int> _getAddedIndices(List<T> before, List<T> after) {
    return after
        .whereNot((e) => before.contains(e))
        .map((e) => after.indexOf(e));
  }
}
