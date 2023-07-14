import 'package:bloc/bloc.dart';
import 'package:ez_badminton_admin_app/list_sorting/comparator/list_sorting_comparator.dart';

class ListSortingCubit<T> extends Cubit<ListSortingComparator<T>> {
  ListSortingCubit({
    required this.defaultComparator,
    required this.comparators,
  }) : super(defaultComparator);

  /// This comparator will be emitted when a comparator is toggled off
  final ListSortingComparator<T> defaultComparator;
  final List<ListSortingComparator<T>> comparators;

  /// Toggles the comparator between
  /// [ComparatorMode.ascending], [ComparatorMode.descending] and default.
  /// When the comparator is initially activated it goes into
  /// [ComparatorMode.ascending].
  void comparatorToggled<P extends ListSortingComparator<T>>() {
    ListSortingComparator<T> nextComparator;

    if (state is P) {
      switch (state.mode) {
        case ComparatorMode.ascending:
          nextComparator = state.copyWith(ComparatorMode.descending);
          break;
        default:
          nextComparator = defaultComparator;
          break;
      }
    } else {
      nextComparator = getComparator<P>().copyWith(ComparatorMode.ascending);
    }

    emit(nextComparator);
  }

  C getComparator<C extends ListSortingComparator<T>>() {
    Iterable<C> comparatorsOfType = comparators.whereType<C>();
    assert(
      comparatorsOfType.isNotEmpty,
      'A ListSortingComparator of type ${C.toString()} can not be found',
    );
    return comparatorsOfType.first;
  }
}
