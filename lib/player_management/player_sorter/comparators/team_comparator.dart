import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/list_sorting/comparator/list_sorting_comparator.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

class TeamComparator extends ListSortingComparator<Player> {
  TeamComparator({
    required this.competition,
  }) : _teams = sortTeams(competition, competition.registrations);

  final Competition competition;
  final List<Team> _teams;

  @override
  Comparator<Player> get comparator => _comparator;

  int _comparator(Player a, Player b) {
    return _playerTeamIndex(a).compareTo(_playerTeamIndex(b));
  }

  int _playerTeamIndex(Player player) {
    Team? team = _teams.firstWhereOrNull((t) => t.players.contains(player));

    if (team == null) {
      return -1;
    }

    int teamIndex = _teams.indexOf(team);

    int playerIndex = teamIndex * 2 + team.players.indexOf(player);

    return playerIndex;
  }

  /// Sorts the teams that are registered in the [competition] by their seed and
  /// by the names of the players.
  static List<Team> sortTeams(Competition competition, List<Team> teams) {
    Comparator<Team> teamComparator = nestComparators(
      (a, b) => _teamStateComparator(competition, a, b),
      (a, b) => _teamStateSecondaryComparator(competition, a, b),
    );
    return teams.sorted(teamComparator).toList();
  }

  static int _teamStateSecondaryComparator(
      Competition competition, Team a, Team b) {
    _TeamState teamState = _teamState(competition, a);

    switch (teamState) {
      case _TeamState.seeded:
        int seedA = competition.seeds.indexOf(a);
        int seedB = competition.seeds.indexOf(b);
        return seedA.compareTo(seedB);
      default:
        String teamNameA = _teamName(a);
        String teamNameB = _teamName(b);
        return teamNameA.compareTo(teamNameB);
    }
  }

  static int _teamStateComparator(Competition competition, Team a, Team b) {
    return _teamState(competition, a)
        .index
        .compareTo(_teamState(competition, b).index);
  }

  static _TeamState _teamState(Competition competition, Team team) {
    if (competition.seeds.contains(team)) {
      return _TeamState.seeded;
    }
    if (competition.teamSize == team.players.length) {
      return _TeamState.normal;
    } else {
      return _TeamState.incomplete;
    }
  }

  static String _teamName(Team team) {
    return team.players
        .map((p) => display_strings.playerName(p))
        .sortedBy((name) => name)
        .join();
  }

  @override
  ListSortingComparator<Player> copyWith(ComparatorMode mode) {
    throw UnimplementedError();
  }
}

enum _TeamState {
  seeded,
  normal,
  incomplete,
}
