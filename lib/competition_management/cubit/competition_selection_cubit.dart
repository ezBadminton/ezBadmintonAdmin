import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

part 'competition_selection_state.dart';

class CompetitionSelectionCubit
    extends CollectionFetcherCubit<CompetitionSelectionState> {
  CompetitionSelectionCubit({
    required CollectionRepository<Competition> competitionRepository,
  }) : super(
          collectionRepositories: [
            competitionRepository,
          ],
          CompetitionSelectionState(),
        ) {
    loadCollections();
    subscribeToCollectionUpdates(
      competitionRepository,
      _onCompetitionCollectionUpdate,
    );
  }

  void loadCollections() {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    fetchCollectionsAndUpdateState(
      [
        collectionFetcher<Competition>(),
      ],
      onSuccess: (updatedState) {
        emit(updatedState.copyWith(
          loadingStatus: LoadingStatus.done,
          displayCompetitions: updatedState.getCollection<Competition>(),
        ));
      },
      onFailure: () {
        emit(state.copyWith(loadingStatus: LoadingStatus.failed));
      },
    );
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
      CollectionUpdateEvent<Competition> event) {
    Competition updated = event.model;
    if (state.selectedCompetitions.contains(updated)) {
      List<Competition> selected = List.of(state.selectedCompetitions);
      selected.removeWhere((c) => c.id == updated.id);
      selected.add(updated);

      emit(state.copyWith(selectedCompetitions: selected));
    }
  }
}
