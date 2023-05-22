import 'package:bloc/bloc.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_filter_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'player_list_state.dart';

class PlayerListCubit extends Cubit<PlayerListState> {
  PlayerListCubit({
    required CollectionRepository<Player> playerRepository,
    required CollectionRepository<Competition> competitionRepository,
  })  : _competitionRepository = competitionRepository,
        _playerRepository = playerRepository,
        super(const PlayerListState()) {
    loadPlayerData();
  }

  final CollectionRepository<Player> _playerRepository;
  final CollectionRepository<Competition> _competitionRepository;

  late List<Competition> _competitions;

  void loadPlayerData() async {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    var loadingResults = await Future.wait([
      _fetchPlayerList(),
      _fetchCompetitionList(),
    ]);
    var players = loadingResults[0] as List<Player>?;
    var competitions = loadingResults[1] as List<Competition>?;
    _finishLoading(players, competitions);
  }

  Future<List<Player>?> _fetchPlayerList() async {
    List<Player> players;
    try {
      players = await _playerRepository.getList(
        expand: ExpansionTree(Player.expandedFields),
      );
    } on CollectionFetchException {
      return null;
    }
    return List.unmodifiable(players);
  }

  Future<List<Competition>?> _fetchCompetitionList() async {
    List<Competition> competitions;
    try {
      competitions = await _competitionRepository.getList(
        expand: ExpansionTree(Competition.expandedFields)
          ..expandWith(Team, Team.expandedFields),
      );
    } on CollectionFetchException {
      return null;
    }
    return competitions;
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

  void _finishLoading(List<Player>? players, List<Competition>? competitions) {
    if (players == null || competitions == null) {
      emit(state.copyWith(loadingStatus: LoadingStatus.failed));
    } else {
      var playerCompetitions = _mapPlayerCompetitions(players, competitions);
      _competitions = competitions;
      var newState = state.copyWith(
        allPlayers: players,
        filteredPlayers: players,
        playerCompetitions: playerCompetitions,
        loadingStatus: LoadingStatus.done,
      );
      emit(newState);
    }
  }

  void filterChanged(Map<Type, Predicate> filters) {
    if (state.loadingStatus != LoadingStatus.done) {
      return;
    }
    var filtered = state.allPlayers;
    List<Player>? filteredByCompetition;
    if (filters.containsKey(Player)) {
      filtered = filtered.where(filters[Player]!).toList();
    }
    if (filters.containsKey(Competition)) {
      var filteredCompetitions =
          _competitions.where(filters[Competition]!).toList();
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
