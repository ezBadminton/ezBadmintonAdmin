part of 'competition_selection_cubit.dart';

class CompetitionSelectionState {
  CompetitionSelectionState({
    this.selectedCompetitions = const [],
    this.displayCompetitions = const [],
  }) : selectionTristate = _getSelectionTristate(
          selectedCompetitions,
          displayCompetitions,
        );

  final List<Competition> selectedCompetitions;
  final List<Competition> displayCompetitions;

  final bool? selectionTristate;

  CompetitionSelectionState copyWith({
    List<Competition>? selectedCompetitions,
    List<Competition>? displayCompetitions,
  }) {
    return CompetitionSelectionState(
      selectedCompetitions: selectedCompetitions ?? this.selectedCompetitions,
      displayCompetitions: displayCompetitions ?? this.displayCompetitions,
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
