part of 'competition_selection_cubit.dart';

class CompetitionSelectionState
    extends CollectionFetcherState<CompetitionSelectionState> {
  CompetitionSelectionState({
    this.loadingStatus = LoadingStatus.loading,
    this.selectedCompetition = const SelectionInput.pure(value: null),
    super.collections = const {},
  });

  final LoadingStatus loadingStatus;

  final SelectionInput<Competition> selectedCompetition;

  CompetitionSelectionState copyWith({
    LoadingStatus? loadingStatus,
    SelectionInput<Competition>? selectedCompetition,
    Map<Type, List<Model>>? collections,
  }) {
    return CompetitionSelectionState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      selectedCompetition: selectedCompetition ?? this.selectedCompetition,
      collections: collections ?? this.collections,
    );
  }
}
