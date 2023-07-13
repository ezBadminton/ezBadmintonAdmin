import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

part 'checkbox_group_state.dart';

class CheckboxGroupCubit<T extends Object>
    extends Cubit<CheckboxGroupState<T>> {
  CheckboxGroupCubit({
    required List<T> elements,
    List<T> intialEnabledElements = const [],
    required this.onToggle,
  }) : super(
          CheckboxGroupState(
            allElements: elements,
            enabledElements: intialEnabledElements,
          ),
        );

  final void Function(T toggledElement) onToggle;

  void enabledElementsChanged(List<T> enabledElements) {
    if (!listEquals(state.enabledElements, enabledElements)) {
      emit(state.copyWith(enabledElements: enabledElements));
    }
  }

  void invertSuperCheckboxChanged(bool invertSuperCheckbox) {
    if (state.invertSuperCheckbox != invertSuperCheckbox) {
      emit(state.copyWith(invertSuperCheckbox: invertSuperCheckbox));
    }
  }

  bool isElementEnabled(T element) {
    assert(state.allElements.contains(element));

    return state.enabledElements.contains(element);
  }

  void groupToggled() {
    switch (isGroupEnabled()) {
      case true:
        _disableGroup();
        break;
      case false:
        _enableGroup();
        break;
      case null:
        if (state.invertSuperCheckbox) {
          _disableGroup();
        } else {
          _enableGroup();
        }
    }
  }

  void _disableGroup() {
    for (T element in state.enabledElements) {
      onToggle(element);
    }
  }

  void _enableGroup() {
    Iterable<T> disabledElements =
        state.allElements.whereNot((e) => state.enabledElements.contains(e));
    for (T element in disabledElements) {
      onToggle(element);
    }
  }

  /// Returns `false` when zero elements are enabled, `true` when all are
  /// enabled and `null` when parts of the elements are enabled.
  ///
  /// Represents the tristate of the group's super-checkbox.
  bool? isGroupEnabled() {
    if (state.enabledElements.isEmpty) {
      return false;
    } else if (state.enabledElements.length == state.allElements.length) {
      return true;
    } else {
      return null;
    }
  }
}
