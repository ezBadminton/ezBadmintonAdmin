part of 'list_filter_cubit.dart';

@immutable
class ListFilterState implements Equatable {
  const ListFilterState({
    this.filters = const {},
    this.filterPredicates = const {},
  });

  final Map<Type, Predicate> filters;
  final Map<Type, List<FilterPredicate>> filterPredicates;

  @override
  List<Object?> get props => [filters];

  @override
  bool? get stringify => false;
}

// A private ListFilterState to hide the mutable predicate map
class _ListFilterState extends ListFilterState {
  _ListFilterState({
    super.filters = const {},
    super.filterPredicates = const {},
    predicates,
  }) : predicates = predicates ?? {};

  final Map<Type, List<FilterPredicate>> predicates;
}
