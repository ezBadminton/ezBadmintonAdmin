import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/list_sorting/comparator/list_sorting_comparator.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

class TeamComparator extends ListSortingComparator<Player> {
  TeamComparator(List<Team> teams) : _teams = sortTeamsByPlayerNames(teams);

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

  /// Sorts the [teams] alphabetically by the names of the players.
  static List<Team> sortTeamsByPlayerNames(List<Team> teams) {
    return teams
        .sortedBy(
          (t) => t.players
              .map((p) => display_strings.playerName(p))
              .sortedBy((name) => name)
              .join(),
        )
        .toList();
  }

  @override
  ListSortingComparator<Player> copyWith(ComparatorMode mode) {
    throw UnimplementedError();
  }
}
