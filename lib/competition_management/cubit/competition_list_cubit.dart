import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_sorter/comparators/competition_comparator.dart';
import 'package:ez_badminton_admin_app/list_sorting/comparator/list_sorting_comparator.dart';
import 'package:ez_badminton_admin_app/list_sorting/cubit/sorted_list_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

part 'competition_list_state.dart';

class CompetitionListCubit extends CollectionFetcherCubit<CompetitionListState>
    implements SortedListCubit<Competition, CompetitionListState> {
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
          displayCompetitionList: _sortCompetitions(competitions),
          loadingStatus: LoadingStatus.done,
        );
        emit(updatedState);
      },
      onFailure: () {
        emit(state.copyWith(loadingStatus: LoadingStatus.failed));
      },
    );
  }

  @override
  void comparatorChanged(ListSortingComparator<Competition> comparator) {
    emit(state.copyWith(sortingComparator: comparator));
    List<Competition> sorted = _sortCompetitions(state.displayCompetitionList);
    emit(state.copyWith(displayCompetitionList: sorted));
  }

  List<Competition> _sortCompetitions(List<Competition> competitions) {
    return competitions.sorted(state.sortingComparator.comparator);
  }
}
