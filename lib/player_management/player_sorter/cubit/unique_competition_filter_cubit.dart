import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/filter_predicate.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate_producers.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

part 'unique_competition_filter_state.dart';

/// This cubit emits a [Competition] as its state whenever the current player
/// filter is set to display only players of only one unique competition
/// (the registration list of that competition).
///
/// This causes the player list to sort the players by teams so the pairings
/// become visible.
class UniqueCompetitionFilterCubit
    extends CollectionQuerierCubit<UniqueCompetitionFilterState> {
  UniqueCompetitionFilterCubit({
    required CollectionRepository<Tournament> tournamentRepository,
    required CollectionRepository<Competition> competitionRepository,
  }) : super(
          collectionRepositories: [
            tournamentRepository,
            competitionRepository,
          ],
          UniqueCompetitionFilterState(),
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
    UniqueCompetitionFilterState updatedState = state.copyWith(
      collections: collections,
      loadingStatus: LoadingStatus.done,
    );

    emit(updatedState);
  }

  void filterPredicatesChanged(
    Map<Type, List<FilterPredicate>> filterPredicates,
    Map<Type, Predicate> filters,
  ) {
    if (!filterPredicates.containsKey(Competition)) {
      _clearCompetition();
      return;
    }

    List<FilterPredicate> competitionFilters = filterPredicates[Competition]!;

    Tournament tournament = state.getCollection<Tournament>().first;
    bool usePlayingLevels = tournament.usePlayingLevels;
    bool useAgeGroups = tournament.useAgeGroups;

    bool playingLevelFiltered = !usePlayingLevels ||
        _filterGroupCount(competitionFilters, FilterGroup.playingLevel) == 1;

    bool ageGroupFiltered = !useAgeGroups ||
        _filterGroupCount(competitionFilters, FilterGroup.ageGroup) == 1;

    bool disciplineFiltered =
        _filterGroupCount(competitionFilters, FilterGroup.competitionType) == 1;

    FilterPredicate? disciplineFilter = disciplineFiltered
        ? competitionFilters.firstWhere(
            (f) => f.disjunction == FilterGroup.competitionType,
          )
        : null;
    bool isMixed =
        disciplineFiltered && disciplineFilter!.domain == CompetitionType.mixed;

    bool genderCategoryFiltered = isMixed ||
        _filterGroupCount(competitionFilters, FilterGroup.genderCategory) == 1;

    bool isCompetitionFilterUnique = playingLevelFiltered &&
        ageGroupFiltered &&
        disciplineFiltered &&
        genderCategoryFiltered;

    if (!isCompetitionFilterUnique) {
      _clearCompetition();
      return;
    }

    Competition? uniqueCompetition = state
        .getCollection<Competition>()
        .where(filters[Competition]!)
        .firstOrNull;

    emit(state.copyWith(
      competition: SelectionInput.dirty(value: uniqueCompetition),
    ));
  }

  void _clearCompetition() {
    if (state.competition.value != null) {
      emit(state.copyWith(
        competition: const SelectionInput.dirty(value: null),
      ));
    }
  }

  void _onCompetitionCollectionUpdate(
    List<CollectionUpdateEvent<Competition>> events,
  ) {
    CollectionUpdateEvent<Competition>? updateEvent = events.reversed
        .firstWhereOrNull((e) => e.model == state.competition.value);

    if (updateEvent == null) {
      return;
    }

    switch (updateEvent.updateType) {
      case UpdateType.update:
        emit(state.copyWith(
          competition: SelectionInput.dirty(value: updateEvent.model),
        ));
        break;
      case UpdateType.delete:
        _clearCompetition();
        break;
      default:
        break;
    }
  }

  static int _filterGroupCount(
    List<FilterPredicate> filters,
    FilterGroup filterGroup,
  ) {
    return filters.where((f) => f.disjunction == filterGroup).length;
  }
}
