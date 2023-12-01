import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/utils/sorting.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
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
        updatedState = updatedState.copyWithCompetitionSorting();
        emit(updatedState.copyWith(loadingStatus: LoadingStatus.done));
      },
      onFailure: () {
        emit(state.copyWith(loadingStatus: LoadingStatus.failed));
      },
    );
  }

  void competitionToggled(Competition competition) {
    Competition? selectedCompetition = competition;
    if (state.selectedCompetition.value == competition) {
      selectedCompetition = null;
    }

    competitionSelected(selectedCompetition);
  }

  void competitionSelected(Competition? selectedCompetition) {
    emit(state.copyWith(
      selectedCompetition: SelectionInput.dirty(value: selectedCompetition),
    ));
  }

  void _onCompetitionCollectionUpdate(
      CollectionUpdateEvent<Competition> event) {
    if (state.selectedCompetition.value == event.model) {
      switch (event.updateType) {
        case UpdateType.update:
          emit(state.copyWith(
            selectedCompetition: SelectionInput.dirty(value: event.model),
          ));
          break;
        case UpdateType.delete:
          emit(state.copyWith(
            selectedCompetition: const SelectionInput.dirty(value: null),
          ));
          break;
        case UpdateType.create:
          break;
      }
    }

    loadCollections();
  }
}
