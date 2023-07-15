import 'package:ez_badminton_admin_app/list_sorting/comparator/list_sorting_comparator.dart';
import 'package:ez_badminton_admin_app/list_sorting/cubit/list_sorting_cubit.dart';
import 'package:ez_badminton_admin_app/list_sorting/cubit/sorted_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A clickable column header that will cycle through sorted list states
class SortableColumnHeader<
    T,
    ComparatorType extends ListSortingComparator<T>,
    SortingCubit extends ListSortingCubit<T>,
    ListCubit extends SortedListCubit<T, ListState>,
    ListState extends SortedListState<T>> extends StatelessWidget {
  const SortableColumnHeader({
    super.key,
    required this.width,
    required this.title,
  });

  final double width;
  final String title;

  @override
  Widget build(BuildContext context) {
    var sortingCubit = context.read<SortingCubit>();
    return BlocListener<SortingCubit, ListSortingComparator<T>>(
      listenWhen: (previous, current) =>
          current is ComparatorType ||
          (previous is ComparatorType &&
              current == sortingCubit.defaultComparator),
      listener: (context, comparator) {
        context.read<ListCubit>().comparatorChanged(comparator);
      },
      child: BlocBuilder<ListCubit, ListState>(
        buildWhen: (previous, current) =>
            previous.sortingComparator != current.sortingComparator,
        builder: (context, state) {
          return InkWell(
            onTap: () => sortingCubit.comparatorToggled<ComparatorType>(),
            child: SizedBox(
              width: width,
              child: Row(
                children: [
                  Text(
                    title,
                    overflow: TextOverflow.clip,
                    softWrap: false,
                  ),
                  if (state.sortingComparator is ComparatorType)
                    _sortIcon(state.sortingComparator.mode),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget _sortIcon(ComparatorMode mode) {
    Icon icon;
    switch (mode) {
      case ComparatorMode.ascending:
        icon = const Icon(
          Icons.arrow_upward,
          size: 19,
        );
        break;
      case ComparatorMode.descending:
        icon = const Icon(
          Icons.arrow_downward,
          size: 19,
        );
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 5.0),
      child: icon,
    );
  }
}
