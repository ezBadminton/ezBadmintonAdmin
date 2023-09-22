import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/competition_management/utils/sorting.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

part 'competition_draw_selection_state.dart';

class CompetitionDrawSelectionCubit
    extends CollectionFetcherCubit<CompetitionDrawSelectionState> {
  CompetitionDrawSelectionCubit({
    required CollectionRepository<Competition> competitionRepository,
  }) : super(
          collectionRepositories: [
            competitionRepository,
          ],
          CompetitionDrawSelectionState(),
        ) {
    loadCollections();
    subscribeToCollectionUpdates(
      competitionRepository,
      (_) => loadCollections(),
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

    emit(state.copyWith(
      selectedCompetition: SelectionInput.dirty(value: selectedCompetition),
    ));
  }
}