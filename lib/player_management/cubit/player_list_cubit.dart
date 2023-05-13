import 'package:bloc/bloc.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/list_filter/cubit/list_filter_cubit.dart';
import 'package:meta/meta.dart';

part 'player_list_state.dart';

class PlayerListCubit extends Cubit<PlayerListState> {
  PlayerListCubit({
    required CollectionRepository<Player> playerRepository,
    required CollectionRepository<Competition> competitionRepository,
  })  : _competitionRepository = competitionRepository,
        _playerRepository = playerRepository,
        super(const PlayerListState()) {
    Future.wait([
      _populateCompetitionList(),
      _populatePlayerList(),
    ]).then(
      (_) => _mapPlayerCompetitions(),
    );
  }

  final CollectionRepository<Player> _playerRepository;
  final CollectionRepository<Competition> _competitionRepository;

  Future<void> _populatePlayerList() async {
    var players = await _playerRepository.getList(
      expand: ExpansionTree(Player.expandedFields),
    );
    players = List.unmodifiable(players);
    var newState =
        state.copyWith(allPlayers: players, filteredPlayers: players);
    emit(newState);
  }

  Future<void> _populateCompetitionList() async {
    var competitions = await _competitionRepository.getList(
      expand: ExpansionTree(Competition.expandedFields)
        ..expandWith(Team, Team.expandedFields),
    );
    competitions = List.unmodifiable(competitions);
    var newState = state.copyWith(competitions: competitions);
    emit(newState);
  }

  void _mapPlayerCompetitions() {
    var playerCompetitions = {
      for (var p in state.allPlayers) p: <Competition>[]
    };
    for (var competition in state.competitions) {
      var teams = competition.registrations;
      var players =
          teams.map((t) => t.players).expand((playerList) => playerList);
      for (var player in players) {
        playerCompetitions[player]!.add(competition);
      }
    }
    var newState = state.copyWith(playerCompetitions: playerCompetitions);
    emit(newState);
  }

  void filterChanged(Map<Type, Predicate> filters) {
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
