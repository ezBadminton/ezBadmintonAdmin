import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/list_sorting/comparator/list_sorting_comparator.dart';
import 'package:ez_badminton_admin_app/list_sorting/cubit/sorted_list_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/models/competition_registration.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/comparators/creation_date_comparator.dart';
import 'package:ez_badminton_admin_app/player_management/utils/competition_registration.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/filter_predicate.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'player_list_state.dart';

class PlayerListCubit extends CollectionQuerierCubit<PlayerListState>
    implements SortedListCubit<Player, PlayerListState> {
  PlayerListCubit({
    required CollectionRepository<Player> playerRepository,
    required CollectionRepository<Competition> competitionRepository,
    required CollectionRepository<PlayingLevel> playingLevelRepository,
    required CollectionRepository<AgeGroup> ageGroupRepository,
    required CollectionRepository<Club> clubRepository,
  }) : super(
          collectionRepositories: [
            competitionRepository,
            playerRepository,
            playingLevelRepository,
            ageGroupRepository,
            clubRepository,
          ],
          const PlayerListState(),
        );

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    List<CollectionUpdateEvent<Model>> updateEvents,
  ) {
    bool doPlayerUpdate = updateEvents.firstWhereOrNull((e) =>
                e is CollectionUpdateEvent<Player> ||
                e is CollectionUpdateEvent<Competition>) !=
            null ||
        updateEvents.isEmpty;

    PlayerListState updatedState = state.copyWith(
      collections: collections,
      loadingStatus: LoadingStatus.done,
    );

    if (doPlayerUpdate) {
      var playerCompetitions = mapCompetitionRegistrations(
        updatedState.getCollection<Player>(),
        updatedState.getCollection<Competition>(),
      );
      updatedState = updatedState.copyWith(
        competitionRegistrations: playerCompetitions,
        filteredPlayers: _sortPlayers(updatedState.getCollection<Player>()),
      );
    }

    emit(updatedState);
    filterChanged(null);
  }

  void filterChanged(Map<Type, Predicate>? filters) {
    // Calling with filters == null just reapplies the current filters
    filters = filters ?? state.filters;
    var filtered = state.getCollection<Player>();
    List<Player>? filteredByCompetition;
    if (filters.containsKey(Player)) {
      filtered = filtered.where(filters[Player]!).toList();
    }
    if (filters.containsKey(Competition)) {
      var filteredCompetitions = state
          .getCollection<Competition>()
          .where(filters[Competition]!)
          .toList();
      filteredByCompetition = filteredCompetitions
          .expand((comp) => comp.registrations)
          .expand((team) => team.players)
          .toList();
    }
    if (filteredByCompetition != null) {
      filtered = filtered
          .where((player) => filteredByCompetition!.contains(player))
          .toList();
    }
    var newState = state.copyWith(
      filteredPlayers: _sortPlayers(filtered),
      filters: filters,
    );
    emit(newState);
  }

  @override
  void comparatorChanged(ListSortingComparator<Player> comparator) {
    emit(state.copyWith(sortingComparator: comparator));
    List<Player> sorted = _sortPlayers(state.filteredPlayers);
    emit(state.copyWith(filteredPlayers: sorted));
  }

  List<Player> _sortPlayers(List<Player> players) {
    Comparator<Player> comparator = state.sortingComparator.comparator;
    return players.sorted(comparator);
  }
}
