import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/list_sorting/comparator/list_sorting_comparator.dart';
import 'package:ez_badminton_admin_app/list_sorting/cubit/sorted_list_cubit.dart';
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
    required ModelStore<Player> playerStore,
    required ModelStore<Competition> competitoinStore,
    required ModelStore<Registration> registrationStore,
    required ModelStore<PlayingLevel> playingLevelStore,
    required ModelStore<AgeGroup> ageGroupStore,
    required ModelStore<Club> clubStore,
  }) : super(
          modelStores: [
            playerStore,
            competitoinStore,
            registrationStore,
            playingLevelStore,
            ageGroupStore,
            clubStore,
          ],
          const PlayerListState(),
        );

  factory PlayerListCubit.fromContext(BuildContext context) {
    return PlayerListCubit(
      playerStore: RepositoryProvider.of(context),
      competitoinStore: RepositoryProvider.of(context),
      registrationStore: RepositoryProvider.of(context),
      playingLevelStore: RepositoryProvider.of(context),
      ageGroupStore: RepositoryProvider.of(context),
      clubStore: RepositoryProvider.of(context),
    );
  }

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    List<CollectionUpdateEvent<Model>>? updateEvents,
  ) {
    bool doPlayerUpdate = updateEvents == null ||
        updateEvents.any(
          (update) => update is CollectionUpdateEvent<Player>,
        ) ||
        updateEvents.any(
          (update) => update is CollectionUpdateEvent<Registration>,
        );

    PlayerListState updatedState = state.copyWith(
      collections: collections,
      loadingStatus: LoadingStatus.done,
    );

    if (doPlayerUpdate) {
      final playerCompetitions = mapCompetitionRegistrations(
        updatedState.getCollection<Registration>(),
      );
      final playersLookingForTeam = _getPlayersLookingForTeam(
        playerCompetitions,
      );
      updatedState = updatedState.copyWith(
        competitionRegistrations: playerCompetitions,
        playersLookingForTeam: playersLookingForTeam,
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

  Set<Player> _getPlayersLookingForTeam(
    Map<Player, List<Registration>> playerRegistrations,
  ) {
    return playerRegistrations.keys.where((player) {
      final registrations = playerRegistrations[player]!;
      return registrations.any(
        (registration) {
          final currentTeamSize = registration.team.players.length;
          final wantedTeamSize = registration.competition.teamSize;
          return currentTeamSize < wantedTeamSize;
        },
      );
    }).toSet();
  }
}
