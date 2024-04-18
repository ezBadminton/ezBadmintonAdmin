part of 'competition_multi_selection_cubit.dart';

class CompetitionMultiSelectionState extends CollectionQuerierState {
  const CompetitionMultiSelectionState({
    this.selectedCompetitions = const [],
    this.loadingStatus = LoadingStatus.loading,
    this.collections = const [],
  });

  final List<Competition> selectedCompetitions;

  @override
  final LoadingStatus loadingStatus;
  @override
  final List<List<Model>> collections;

  CompetitionMultiSelectionState copyWith({
    List<Competition>? selectedCompetitions,
    LoadingStatus? loadingStatus,
    List<List<Model>>? collections,
  }) {
    return CompetitionMultiSelectionState(
      selectedCompetitions: selectedCompetitions ?? this.selectedCompetitions,
      loadingStatus: loadingStatus ?? this.loadingStatus,
      collections: collections ?? this.collections,
    );
  }
}
