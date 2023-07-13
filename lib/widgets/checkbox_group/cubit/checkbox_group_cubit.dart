import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';

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
    emit(state.copyWith(enabledElements: enabledElements));
  }

  bool isElementEnabled(T element) {
    assert(state.allElements.contains(element));

    return state.enabledElements.contains(element);
  }

  void groupToggled() {
    if (isGroupEnabled() == true) {
      for (T element in state.enabledElements) {
        onToggle(element);
      }
    } else {
      Iterable<T> disabledElements =
          state.allElements.whereNot((e) => state.enabledElements.contains(e));
      for (T element in disabledElements) {
        onToggle(element);
      }
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
