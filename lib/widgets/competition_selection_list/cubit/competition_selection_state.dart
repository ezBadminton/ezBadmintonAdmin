part of 'competition_selection_cubit.dart';

class CompetitionSelectionState extends CollectionQuerierState {
  CompetitionSelectionState({
    this.loadingStatus = LoadingStatus.loading,
    this.selectedCompetition = const SelectionInput.pure(value: null),
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;

  final SelectionInput<Competition> selectedCompetition;

  @override
  final List<List<Model>> collections;

  CompetitionSelectionState copyWith({
    LoadingStatus? loadingStatus,
    SelectionInput<Competition>? selectedCompetition,
    List<List<Model>>? collections,
  }) {
    return CompetitionSelectionState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      selectedCompetition: selectedCompetition ?? this.selectedCompetition,
      collections: collections ?? this.collections,
    );
  }
}
