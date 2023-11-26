import 'package:bloc/bloc.dart';

/// A cubit that maintains a map of [T] objets to a bool value.
///
/// The state can be updated by toggling the bool of the individual items.
class SelectionCubit<T> extends Cubit<Map<T, bool>> {
  /// Creates a [SelectionCubit] for the given [items].
  ///
  /// The initial bool value for all items is [initiallyAllSelected].
  SelectionCubit({
    required List<T> items,
    bool initiallyAllSelected = true,
  }) : super({for (T item in items) item: initiallyAllSelected});

  void itemToggled(T item) {
    if (!state.keys.contains(item)) {
      throw Exception('This item is not part of the selectable items');
    }

    Map<T, bool> newState = Map.of(state)
      ..update(item, (selected) => !selected);

    emit(newState);
  }
}
