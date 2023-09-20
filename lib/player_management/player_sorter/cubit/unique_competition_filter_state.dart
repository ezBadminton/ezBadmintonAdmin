part of 'unique_competition_filter_cubit.dart';

class UniqueCompetitionFilterState
    extends CollectionFetcherState<UniqueCompetitionFilterState> {
  UniqueCompetitionFilterState({
    this.loadingStatus = LoadingStatus.loading,
    this.competition = const SelectionInput.pure(value: null),
    super.collections = const {},
  });

  final LoadingStatus loadingStatus;

  final SelectionInput<Competition> competition;

  UniqueCompetitionFilterState copyWith({
    LoadingStatus? loadingStatus,
    SelectionInput<Competition>? competition,
    Map<Type, List<Model>>? collections,
  }) {
    return UniqueCompetitionFilterState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      competition: competition ?? this.competition,
      collections: collections ?? this.collections,
    );
  }
}
