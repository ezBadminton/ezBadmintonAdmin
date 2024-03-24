import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

part 'competition_selection_state.dart';

class CompetitionSelectionCubit
    extends CollectionQuerierCubit<CompetitionSelectionState> {
  CompetitionSelectionCubit({
    required CollectionRepository<Competition> competitionRepository,
  }) : super(
          collectionRepositories: [
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
    List<CollectionUpdateEvent<Model>> updateEvents,
  ) {
    if (updateEvents.isEmpty) {
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
    List<CollectionUpdateEvent<Competition>> events,
  ) {
    List<Competition> selected = List.of(state.selectedCompetitions);

    List<Competition> updated =
        events.map((e) => e.model).where((c) => selected.contains(c)).toList();

    if (updated.isEmpty) {
      return;
    }

    for (Competition u in updated) {
      selected.removeWhere((c) => c.id == u.id);
    }

    selected.addAll(updated);

    emit(state.copyWith(selectedCompetitions: selected));
  }
}
