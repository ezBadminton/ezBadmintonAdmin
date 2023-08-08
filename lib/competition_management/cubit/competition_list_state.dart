part of 'competition_list_cubit.dart';

class CompetitionListState extends CollectionFetcherState<CompetitionListState>
    implements SortedListState<Competition> {
  CompetitionListState({
    this.loadingStatus = LoadingStatus.loading,
    this.displayCompetitionList = const [],
    this.filters = const {},
    this.sortingComparator = const CompetitionComparator(),
    super.collections = const {},
  });

  final LoadingStatus loadingStatus;

  final List<Competition> displayCompetitionList;

  final Map<Type, Predicate> filters;

  @override
  final ListSortingComparator<Competition> sortingComparator;

  CompetitionListState copyWith({
    LoadingStatus? loadingStatus,
    List<Competition>? displayCompetitionList,
    Map<Type, Predicate>? filters,
    ListSortingComparator<Competition>? sortingComparator,
    Map<Type, List<Model>>? collections,
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
