part of 'competition_selection_cubit.dart';

class CompetitionSelectionState extends CollectionQuerierState {
  CompetitionSelectionState({
    this.loadingStatus = LoadingStatus.loading,
    this.selectedCompetitions = const [],
    this.displayCompetitions = const [],
    this.collections = const [],
  }) : selectionTristate = _getSelectionTristate(
          selectedCompetitions,
          displayCompetitions,
        );

  @override
  final LoadingStatus loadingStatus;

  final List<Competition> selectedCompetitions;
  final List<Competition> displayCompetitions;

  final bool? selectionTristate;

  @override
  final List<List<Model>> collections;

  CompetitionSelectionState copyWith({
    LoadingStatus? loadingStatus,
    List<Competition>? selectedCompetitions,
    List<Competition>? displayCompetitions,
    List<List<Model>>? collections,
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
