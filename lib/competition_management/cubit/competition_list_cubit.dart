import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_sorter/comparators/competition_comparator.dart';
import 'package:ez_badminton_admin_app/list_sorting/comparator/list_sorting_comparator.dart';
import 'package:ez_badminton_admin_app/list_sorting/cubit/sorted_list_cubit.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/filter_predicate.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

part 'competition_list_state.dart';

class CompetitionListCubit extends CollectionQuerierCubit<CompetitionListState>
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
        );

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    List<CollectionUpdateEvent<Model>> updateEvents,
  ) {
    CompetitionListState updatedState = state.copyWith(
      collections: collections,
      loadingStatus: LoadingStatus.done,
    );
    emit(updatedState);

    filterChanged(null);
  }

  /// Called when the filters for the list changed. The displayCompetitionList
  /// is updated accordingly.
  ///
  /// Call with [filters] = `null` to update the displayCompetitionList while
  /// keeping the same filters.
  void filterChanged(Map<Type, Predicate>? filters) {
    filters = filters ?? state.filters;
    List<Competition> filtered = state.getCollection<Competition>();
    if (filters.containsKey(Competition)) {
      filtered = filtered.where(filters[Competition]!).toList();
    }

    CompetitionListState newState = state.copyWith(
      displayCompetitionList: _sortCompetitions(filtered),
      filters: filters,
    );
    emit(newState);
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
