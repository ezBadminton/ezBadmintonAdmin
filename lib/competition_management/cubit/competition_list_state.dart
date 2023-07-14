part of 'competition_list_cubit.dart';

class CompetitionListState
    extends CollectionFetcherState<CompetitionListState> {
  CompetitionListState({
    this.loadingStatus = LoadingStatus.loading,
    this.displayCompetitionList = const [],
    super.collections = const {},
  });

  final LoadingStatus loadingStatus;

  final List<Competition> displayCompetitionList;

  CompetitionListState copyWith({
    LoadingStatus? loadingStatus,
    List<Competition>? displayCompetitionList,
    Map<Type, List<Model>>? collections,
  }) {
    return CompetitionListState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      displayCompetitionList:
          displayCompetitionList ?? this.displayCompetitionList,
      collections: collections ?? this.collections,
    );
  }
}
