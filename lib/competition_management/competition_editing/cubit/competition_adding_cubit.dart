import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/competition_management/models/competition_category.dart';
import 'package:ez_badminton_admin_app/competition_management/utils/sorting.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';

part 'competition_adding_state.dart';

class CompetitionAddingCubit
    extends CollectionFetcherCubit<CompetitionAddingState> {
  CompetitionAddingCubit({
    required CollectionRepository<Competition> competitionRepository,
    required CollectionRepository<AgeGroup> ageGroupRepository,
    required CollectionRepository<PlayingLevel> playingLevelRepository,
    required CollectionRepository<Tournament> tournamentRepository,
  }) : super(
          collectionRepositories: [
            competitionRepository,
            ageGroupRepository,
            playingLevelRepository,
            tournamentRepository
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
        collectionFetcher<Tournament>(),
      ],
      onSuccess: (updatedState) {
        updatedState = updatedState.copyWithAgeGroupSorting();
        updatedState = updatedState.copyWithPlayingLevelSorting();

        emit(updatedState.copyWith(loadingStatus: LoadingStatus.done));
      },
      onFailure: () {
        emit(state.copyWith(loadingStatus: LoadingStatus.failed));
      },
    );
  }

  void ageGroupsChanged(List<AgeGroup> ageGroups) {
    ageGroups = ageGroups..sort(compareAgeGroups);
    emit(state.copyWith(ageGroups: ageGroups));
  }

  void playingLevelsChanged(List<PlayingLevel> playingLevels) {
    playingLevels = playingLevels..sortBy<num>((lvl) => lvl.index);
    emit(state.copyWith(playingLevels: playingLevels));
  }

  void competitionCategoriesChanged(
      List<CompetitionCategory> competitionCategories) {
    emit(state.copyWith(competitionCategories: competitionCategories));
  }
}
