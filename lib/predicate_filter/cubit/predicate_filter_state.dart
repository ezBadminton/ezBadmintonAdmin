part of 'predicate_filter_cubit.dart';

@immutable
class PredicateFilterState implements Equatable {
  const PredicateFilterState({
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

// A private PredicateFilterState to hide the mutable predicate map
class _PredicateFilterState extends PredicateFilterState {
  _PredicateFilterState({
    super.filters = const {},
    super.filterPredicates = const {},
    predicates,
  }) : predicates = predicates ?? {};

  final Map<Type, List<FilterPredicate>> predicates;
}
