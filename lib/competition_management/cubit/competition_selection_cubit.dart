import 'package:collection_repository/collection_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'competition_selection_state.dart';

class CompetitionSelectionCubit extends Cubit<CompetitionSelectionState> {
  CompetitionSelectionCubit() : super(CompetitionSelectionState());

  void displayCompetitionsChanged(List<Competition> displayCompeitions) {
    CompetitionSelectionState updatedState =
        state.copyWith(displayCompetitions: displayCompeitions);
    updatedState = _updateSelection(updatedState);
    emit(updatedState);
  }

  void allCompetitionsToggled() {
    switch (state.selectionTristate) {
      case true:
        emit(state.copyWith(selectedCompetitions: []));
        break;
      case false:
      case null:
        emit(state.copyWith(selectedCompetitions: state.displayCompetitions));
        break;
    }
  }

  void competitionToggled(Competition competition) {
    List<Competition> selected = List.of(state.selectedCompetitions);
    if (selected.contains(competition)) {
      selected.remove(competition);
    } else {
      selected.add(competition);
    }
    emit(state.copyWith(selectedCompetitions: selected));
  }

  // Remove selected items that are no longer in the display list
  CompetitionSelectionState _updateSelection(
    CompetitionSelectionState updatedState,
  ) {
    List<Competition> updatedSelection =
        List.of(updatedState.selectedCompetitions)
            .where(
              (competition) =>
                  updatedState.displayCompetitions.contains(competition),
            )
            .toList();
    return updatedState.copyWith(selectedCompetitions: updatedSelection);
  }
}
