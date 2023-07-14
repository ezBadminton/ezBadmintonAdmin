import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

part 'competition_list_state.dart';

class CompetitionListCubit
    extends CollectionFetcherCubit<CompetitionListState> {
  CompetitionListCubit({
    required CollectionRepository<Competition> competitionRepository,
    required CollectionRepository<Tournament> tournamentRepository,
    required CollectionRepository<AgeGroup> ageGroupRepository,
    required CollectionRepository<PlayingLevel> playingLevelRepository,
  }) : super(
          collectionRepositories: [
            competitionRepository,
            tournamentRepository,
            ageGroupRepository,
            playingLevelRepository,
          ],
          CompetitionListState(),
        ) {
    loadCollections();
    subscribeToCollectionUpdates(
      competitionRepository,
      (_) => loadCollections(),
    );
    subscribeToCollectionUpdates(
      tournamentRepository,
      (_) => loadCollections(),
    );
    subscribeToCollectionUpdates(
      ageGroupRepository,
      (_) => loadCollections(),
    );
    subscribeToCollectionUpdates(
      playingLevelRepository,
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
        collectionFetcher<Tournament>(),
        collectionFetcher<AgeGroup>(),
        collectionFetcher<PlayingLevel>(),
      ],
      onSuccess: (updatedState) {
        List<Competition> competitions =
            updatedState.getCollection<Competition>();
        updatedState = updatedState.copyWith(
          displayCompetitionList: competitions,
          loadingStatus: LoadingStatus.done,
        );
        emit(updatedState);
      },
      onFailure: () {
        emit(state.copyWith(loadingStatus: LoadingStatus.failed));
      },
    );
  }
}
