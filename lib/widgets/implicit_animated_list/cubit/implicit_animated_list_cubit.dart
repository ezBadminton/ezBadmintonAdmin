import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

part 'implicit_animated_list_state.dart';

class ImplicitAnimatedListCubit<T> extends Cubit<ImplicitAnimatedListState<T>> {
  ImplicitAnimatedListCubit({this.reorderable = false})
      : super(ImplicitAnimatedListState());

  final bool reorderable;

  void elementsChanged(List<T> elements) {
    List<List<T>> changedElements =
        _getChangedElements(state.elements, elements);
    emit(state.copyWith(
      elements: elements,
      previousElements: state.elements,
      removedElements: changedElements[0],
      addedElements: changedElements[1],
    ));
  }

  List<List<T>> _getChangedElements(List<T> before, List<T> after) {
    List<T> removedElements = before
        .whereNot((e) => after.contains(e))
        //.map((e) => before.indexOf(e))
        .toList();

    List<T> addedElements = after
        .whereNot((e) => before.contains(e))
        //.map((e) => after.indexOf(e))
        .toList();

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

    return [removedElements, addedElements];
  }
}
