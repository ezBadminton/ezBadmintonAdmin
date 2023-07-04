import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

part 'implicit_animated_list_state.dart';

class ImplicitAnimatedListCubit<T extends Object>
    extends Cubit<ImplicitAnimatedListState<T>> {
  ImplicitAnimatedListCubit({this.reorderable = false})
      : super(ImplicitAnimatedListState());

  final bool reorderable;

  void elementsChanged(
    List<T> elements, {
    bool Function(T element1, T element2)? elementsEqual,
  }) {
    if (_elementListsEqual(state.elements, elements, elementsEqual)) {
      return;
    }

    elements = List.of(elements);
    List<List<T>> changedElements = _getChangedElements(
      state.elements,
      elements,
      elementsEqual: elementsEqual,
    );

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

  List<List<T>> _getChangedElements(
    List<T> before,
    List<T> after, {
    bool Function(T element1, T element2)? elementsEqual,
  }) {
    List<T> removedElements = before
        .whereNot(
          (e) => _elementsContain(
            after,
            e,
            elementsEqual: elementsEqual,
          ),
        )
        .toList();

    List<T> addedElements = after
        .whereNot(
          (e) => _elementsContain(
            before,
            e,
            elementsEqual: elementsEqual,
          ),
        )
        .toList();

    if (reorderable) {
      List<T> cleanedBefore = List.of(before)
        ..removeWhere(
          (e) => _elementsContain(
            removedElements,
            e,
            elementsEqual: elementsEqual,
          ),
        );
      List<T> cleanedAfter = List.of(after)
        ..removeWhere(
          (e) => _elementsContain(
            addedElements,
            e,
            elementsEqual: elementsEqual,
          ),
        );

      assert(
        cleanedBefore.isEmpty && cleanedAfter.isEmpty ||
            cleanedBefore
                .map(
                  (element) => _elementsContain(
                    cleanedAfter,
                    element,
                    elementsEqual: elementsEqual,
                  ),
                )
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

  bool _elementsContain(
    List<T> elements,
    T element, {
    bool Function(T element1, T element2)? elementsEqual,
  }) {
    elementsEqual ??= (element1, element2) => element1 == element2;

    return elements.firstWhereOrNull((e) => elementsEqual!(e, element)) != null;
  }

  bool _elementListsEqual(
    List<T> elements1,
    List<T> elements2,
    bool Function(T element1, T element2)? elementsEqual,
  ) {
    if (elementsEqual == null) {
      return listEquals(elements1, elements2);
    } else {
      if (elements1.length != elements2.length) {
        return false;
      }

      Iterable<bool> elementEqualities = elements1.mapIndexed(
        (index, element) => elementsEqual(element, elements2[index]),
      );

      return !elementEqualities.contains(false);
    }
  }
}
