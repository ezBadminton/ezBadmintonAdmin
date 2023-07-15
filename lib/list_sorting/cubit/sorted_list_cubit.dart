import 'package:ez_badminton_admin_app/list_sorting/comparator/list_sorting_comparator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SortedListCubit<T, S extends SortedListState<T>>
    implements Cubit<S> {
  void comparatorChanged(ListSortingComparator<T> comparator);
}

abstract class SortedListState<T> {
  ListSortingComparator<T> get sortingComparator;
}
