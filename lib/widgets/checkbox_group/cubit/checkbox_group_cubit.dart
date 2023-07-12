import 'package:bloc/bloc.dart';

part 'checkbox_group_state.dart';

class CheckboxGroupCubit<T extends Object>
    extends Cubit<CheckboxGroupState<T>> {
  CheckboxGroupCubit({
    required List<T> elements,
    List<T> intialEnabledElements = const [],
  }) : super(
          CheckboxGroupState(
            allElements: elements,
            enabledElements: intialEnabledElements,
          ),
        );

  void elementToggled(T element) {
    assert(state.allElements.contains(element));

    List<T> newEnabledElements = List.of(state.enabledElements);
    if (state.enabledElements.contains(element)) {
      newEnabledElements.remove(element);
    } else {
      newEnabledElements.add(element);
    }

    emit(state.copyWith(enabledElements: newEnabledElements));
  }

  bool isElementEnabled(T element) {
    assert(state.allElements.contains(element));

    return state.enabledElements.contains(element);
  }

  void groupToggled() {
    if (isGroupEnabled() == true) {
      emit(state.copyWith(enabledElements: <T>[]));
    } else {
      emit(state.copyWith(enabledElements: List.of(state.allElements)));
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
