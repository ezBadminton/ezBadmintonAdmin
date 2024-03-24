part of 'competition_list_cubit.dart';

class CompetitionListState extends CollectionQuerierState
    implements SortedListState<Competition> {
  CompetitionListState({
    this.loadingStatus = LoadingStatus.loading,
    this.displayCompetitionList = const [],
    this.filters = const {},
    this.sortingComparator = const CompetitionComparator(),
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;

  final List<Competition> displayCompetitionList;

  final Map<Type, Predicate> filters;

  @override
  final ListSortingComparator<Competition> sortingComparator;

  @override
  List<List<Model>> collections;

  CompetitionListState copyWith({
    LoadingStatus? loadingStatus,
    List<Competition>? displayCompetitionList,
    Map<Type, Predicate>? filters,
    ListSortingComparator<Competition>? sortingComparator,
    List<List<Model>>? collections,
  }) {
    return CompetitionListState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      displayCompetitionList:
          displayCompetitionList ?? this.displayCompetitionList,
      filters: filters ?? this.filters,
      sortingComparator: sortingComparator ?? this.sortingComparator,
      collections: collections ?? this.collections,
    );
  }
}
