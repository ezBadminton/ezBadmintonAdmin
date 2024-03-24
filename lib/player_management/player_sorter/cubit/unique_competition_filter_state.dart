part of 'unique_competition_filter_cubit.dart';

class UniqueCompetitionFilterState extends CollectionQuerierState {
  UniqueCompetitionFilterState({
    this.loadingStatus = LoadingStatus.loading,
    this.competition = const SelectionInput.pure(value: null),
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;

  final SelectionInput<Competition> competition;

  @override
  final List<List<Model>> collections;

  UniqueCompetitionFilterState copyWith({
    LoadingStatus? loadingStatus,
    SelectionInput<Competition>? competition,
    List<List<Model>>? collections,
  }) {
    return UniqueCompetitionFilterState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      competition: competition ?? this.competition,
      collections: collections ?? this.collections,
    );
  }
}
