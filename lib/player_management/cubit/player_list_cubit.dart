import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_filter_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'player_list_state.dart';

class PlayerListCubit extends CollectionFetcherCubit<PlayerListState> {
  PlayerListCubit({
    required CollectionRepository<Player> playerRepository,
    required CollectionRepository<Competition> competitionRepository,
    required CollectionRepository<PlayingLevel> playingLevelRepository,
    required CollectionRepository<Club> clubRepository,
    required CollectionRepository<Team> teamRepository,
  }) : super(
          collectionRepositories: [
            competitionRepository,
            playerRepository,
            playingLevelRepository,
            clubRepository,
            teamRepository,
          ],
          const PlayerListState(),
        ) {
    loadPlayerData();
  }

  void loadPlayerData() {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    fetchCollectionsAndUpdateState(
      [
        collectionFetcher<Player>(),
        collectionFetcher<Competition>(),
        collectionFetcher<PlayingLevel>(),
        collectionFetcher<Club>(),
        collectionFetcher<Team>(),
      ],
      onSuccess: (updatedState) {
        var playerCompetitions = _mapPlayerCompetitions(
          updatedState.getCollection<Player>(),
          updatedState.getCollection<Competition>(),
        );
        updatedState = updatedState.copyWith(
          playerCompetitions: playerCompetitions,
          filteredPlayers: updatedState.getCollection<Player>(),
          loadingStatus: LoadingStatus.done,
        );
        emit(updatedState);
        filterChanged(_lastFilters);
      },
      onFailure: () =>
          emit(state.copyWith(loadingStatus: LoadingStatus.failed)),
    );
  }

  static Map<Player, List<Competition>> _mapPlayerCompetitions(
    List<Player> players,
    List<Competition> competitions,
  ) {
    var playerCompetitions = {for (var p in players) p: <Competition>[]};
    for (var competition in competitions) {
      var teams = competition.registrations;
      var players =
          teams.map((t) => t.players).expand((playerList) => playerList);
      for (var player in players) {
        playerCompetitions[player]?.add(competition);
      }
    }
    return playerCompetitions;
  }

  Map<Type, Predicate> _lastFilters = {};
  void filterChanged(Map<Type, Predicate> filters) {
    _lastFilters = filters;
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
      var teams = filteredCompetitions
          .map((comp) => comp.registrations)
          .expand((teamList) => teamList);
      filteredByCompetition = teams
          .map((team) => team.players)
          .expand((playerList) => playerList)
          .toList();
    }
    if (filteredByCompetition != null) {
      filtered = filtered
          .where((player) => filteredByCompetition!.contains(player))
          .toList();
    }
    var newState = state.copyWith(filteredPlayers: filtered);
    emit(newState);
  }
}
