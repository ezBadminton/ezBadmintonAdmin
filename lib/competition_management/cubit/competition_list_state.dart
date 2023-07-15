part of 'competition_list_cubit.dart';

class CompetitionListState extends CollectionFetcherState<CompetitionListState>
    implements SortedListState<Competition> {
  CompetitionListState({
    this.loadingStatus = LoadingStatus.loading,
    this.displayCompetitionList = const [],
    this.sortingComparator = const CompetitionComparator(),
    super.collections = const {},
  });

  final LoadingStatus loadingStatus;

  final List<Competition> displayCompetitionList;
  @override
  final ListSortingComparator<Competition> sortingComparator;

  CompetitionListState copyWith({
    LoadingStatus? loadingStatus,
    List<Competition>? displayCompetitionList,
    ListSortingComparator<Competition>? sortingComparator,
    Map<Type, List<Model>>? collections,
  }) {
    return CompetitionListState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      displayCompetitionList:
          displayCompetitionList ?? this.displayCompetitionList,
      sortingComparator: sortingComparator ?? this.sortingComparator,
      collections: collections ?? this.collections,
    );
  }
}
