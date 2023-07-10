import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/competition_management/models/competition_category.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';

part 'competition_adding_state.dart';

class CompetitionAddingCubit
    extends CollectionFetcherCubit<CompetitionAddingState> {
  CompetitionAddingCubit({
    required CollectionRepository<Competition> competitionRepository,
    required CollectionRepository<AgeGroup> ageGroupRepository,
    required CollectionRepository<PlayingLevel> playingLevelRepository,
  }) : super(
          collectionRepositories: [
            competitionRepository,
            ageGroupRepository,
            playingLevelRepository,
          ],
          const CompetitionAddingState(),
        ) {
    loadCompetitionData();
  }

  void loadCompetitionData() {
    fetchCollectionsAndUpdateState(
      [
        collectionFetcher<Competition>(),
        collectionFetcher<AgeGroup>(),
        collectionFetcher<PlayingLevel>(),
      ],
      onSuccess: (updatedState) {
        emit(updatedState.copyWith(loadingStatus: LoadingStatus.done));
      },
      onFailure: () {
        emit(state.copyWith(loadingStatus: LoadingStatus.failed));
      },
    );
  }

  void ageGroupsChanged(List<AgeGroup> ageGroups) {
    emit(state.copyWith(ageGroups: ageGroups));
  }

  void playingLevelsChanged(List<PlayingLevel> playingLevels) {
    emit(state.copyWith(playingLevels: playingLevels));
  }

  void competitionCategoriesChanged(
      List<CompetitionCategory> competitionCategories) {
    emit(state.copyWith(competitionCategories: competitionCategories));
  }
}
