part of 'competition_selection_cubit.dart';

class CompetitionSelectionState
    extends CollectionFetcherState<CompetitionSelectionState> {
  CompetitionSelectionState({
    this.loadingStatus = LoadingStatus.loading,
    this.selectedCompetitions = const [],
    this.displayCompetitions = const [],
    super.collections = const {},
  }) : selectionTristate = _getSelectionTristate(
          selectedCompetitions,
          displayCompetitions,
        );

  final LoadingStatus loadingStatus;

  final List<Competition> selectedCompetitions;
  final List<Competition> displayCompetitions;

  final bool? selectionTristate;

  CompetitionSelectionState copyWith({
    LoadingStatus? loadingStatus,
    List<Competition>? selectedCompetitions,
    List<Competition>? displayCompetitions,
    Map<Type, List<Model>>? collections,
  }) {
    return CompetitionSelectionState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      selectedCompetitions: selectedCompetitions ?? this.selectedCompetitions,
      displayCompetitions: displayCompetitions ?? this.displayCompetitions,
      collections: collections ?? this.collections,
    );
  }

  static bool? _getSelectionTristate(
    List<Competition> selectedCompetitions,
    List<Competition> displayCompetitions,
  ) {
    if (displayCompetitions.isEmpty || selectedCompetitions.isEmpty) {
      return false;
    }

    if (selectedCompetitions.length < displayCompetitions.length) {
      return null;
    }

    return true;
  }
}
