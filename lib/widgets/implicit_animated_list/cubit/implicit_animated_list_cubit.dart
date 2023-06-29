import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

part 'implicit_animated_list_state.dart';

class ImplicitAnimatedListCubit<T extends Object>
    extends Cubit<ImplicitAnimatedListState<T>> {
  ImplicitAnimatedListCubit({this.reorderable = false})
      : super(ImplicitAnimatedListState());

  final bool reorderable;

  void elementsChanged(List<T> elements) {
    elements = List.of(elements);
    List<List<T>> changedElements =
        _getChangedElements(state.elements, elements);
    emit(state.copyWith(
      elements: elements,
      previousElements: state.elements,
      removedElements: changedElements[0],
      addedElements: changedElements[1],
    ));
  }

  void dragStarted(int draggingIndex) {
    assert(reorderable);
    emit(state.copyWith(draggingIndex: draggingIndex));
  }

  void dragEnded() {
    emit(state.copyWith(draggingIndex: -1));
  }

  List<List<T>> _getChangedElements(List<T> before, List<T> after) {
    List<T> removedElements =
        before.whereNot((e) => after.contains(e)).toList();

    List<T> addedElements = after.whereNot((e) => before.contains(e)).toList();

    if (reorderable) {
      List<T> cleanedBefore = List.of(before)
        ..removeWhere((e) => removedElements.contains(e));
      List<T> cleanedAfter = List.of(after)
        ..removeWhere((e) => addedElements.contains(e));

      assert(
        cleanedBefore.isEmpty && cleanedAfter.isEmpty ||
            cleanedBefore
                .map((element) => cleanedAfter.contains(element))
                .reduce((value, element) => value && element),
      );

      List<T> reorderedElements = cleanedBefore
          .whereIndexed((index, e) => cleanedAfter[index] != e)
          .toList();

      removedElements = [...removedElements, ...reorderedElements];
      addedElements = [...addedElements, ...reorderedElements];
    }

    addedElements.sort((a, b) => after.indexOf(a).compareTo(after.indexOf(b)));

    return [removedElements, addedElements];
  }
}
