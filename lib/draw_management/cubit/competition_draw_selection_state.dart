part of 'competition_draw_selection_cubit.dart';

class CompetitionDrawSelectionState
    extends CollectionFetcherState<CompetitionDrawSelectionState> {
  CompetitionDrawSelectionState({
    this.loadingStatus = LoadingStatus.loading,
    this.selectedCompetition = const SelectionInput.pure(value: null),
    super.collections = const {},
  });

  final LoadingStatus loadingStatus;

  final SelectionInput<Competition> selectedCompetition;

  CompetitionDrawSelectionState copyWith({
    LoadingStatus? loadingStatus,
    SelectionInput<Competition>? selectedCompetition,
    Map<Type, List<Model>>? collections,
  }) {
    return CompetitionDrawSelectionState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      selectedCompetition: selectedCompetition ?? this.selectedCompetition,
      collections: collections ?? this.collections,
    );
  }
}
