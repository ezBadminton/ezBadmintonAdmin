import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

part 'competition_selection_state.dart';

class CompetitionSelectionCubit
    extends CollectionQuerierCubit<CompetitionSelectionState> {
  CompetitionSelectionCubit({
    required ModelStore<Competition> competitionRepository,
  }) : super(
          modelStores: [
            competitionRepository,
          ],
          CompetitionSelectionState(),
        ) {
    subscribeToCollectionUpdates(
      competitionRepository,
      _onCompetitionCollectionUpdate,
    );
  }

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    CollectionUpdateEvent<Model>? updateEvent,
  ) {
    if (updateEvent == null) {
      List<Competition> competitions = collections
          .firstWhere((c) => c is List<Competition>) as List<Competition>;
      CompetitionSelectionState updatedState = state.copyWith(
        displayCompetitions: competitions,
        loadingStatus: LoadingStatus.done,
      );

      emit(updatedState);
    }
  }

  void displayCompetitionsChanged(List<Competition> displayCompetitions) {
    CompetitionSelectionState updatedState =
        state.copyWith(displayCompetitions: displayCompetitions);
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

  void _onCompetitionCollectionUpdate(
    CollectionUpdateEvent<Competition> event,
  ) {
    List<Competition> selected = List.of(state.selectedCompetitions);

    if (!selected.contains(event.model)) {
      return;
    }

    selected.removeWhere((c) => c.id == event.model.id);
    selected.add(event.model);

    emit(state.copyWith(selectedCompetitions: selected));
  }
}
