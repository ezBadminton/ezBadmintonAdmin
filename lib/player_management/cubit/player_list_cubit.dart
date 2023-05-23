import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_fetcher_mixins.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_filter_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'player_list_state.dart';

class PlayerListCubit extends CollectionQuerierCubit<PlayerListState>
    with
        PlayerFetch,
        CompetitionFetch,
        PlayingLevelFetch,
        ClubFetch,
        TeamFetch,
        FetcherBloc {
  PlayerListCubit({
    required CollectionRepository<Player> playerRepository,
    required CollectionRepository<Competition> competitionRepository,
    required CollectionRepository<PlayingLevel> playingLevelRepository,
    required CollectionRepository<Club> clubRepository,
    required CollectionRepository<Team> teamRepository,
  })  : collectionRepositories = [
          competitionRepository,
          playerRepository,
          playingLevelRepository,
          clubRepository,
          teamRepository,
        ],
        super(const PlayerListState()) {
    loadPlayerData();
  }

  @override
  final Iterable<CollectionRepository<Model>> collectionRepositories;

  void loadPlayerData() {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    var newState = state;
    fetchCollectionsAndUpdateState(
      {
        fetchPlayerList: (players) =>
            newState = newState.copyWith(allPlayers: players as List<Player>),
        fetchCompetitionList: (comps) => newState =
            newState.copyWith(competitions: comps as List<Competition>),
        fetchPlayingLevelList: (lvls) => newState =
            newState.copyWith(playingLevels: lvls as List<PlayingLevel>),
        fetchClubList: (clubs) =>
            newState = newState.copyWith(clubs: clubs as List<Club>),
        fetchTeamList: (teams) =>
            newState = newState.copyWith(teams: teams as List<Team>),
      },
      onSuccess: () {
        var playerCompetitions = _mapPlayerCompetitions(
          newState.allPlayers,
          newState.competitions,
        );
        newState = newState.copyWith(
          playerCompetitions: playerCompetitions,
          filteredPlayers: newState.allPlayers,
          loadingStatus: LoadingStatus.done,
        );
        emit(newState);
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
    var filtered = state.allPlayers;
    List<Player>? filteredByCompetition;
    if (filters.containsKey(Player)) {
      filtered = filtered.where(filters[Player]!).toList();
    }
    if (filters.containsKey(Competition)) {
      var filteredCompetitions =
          state.competitions.where(filters[Competition]!).toList();
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
