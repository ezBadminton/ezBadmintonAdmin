import 'package:collection_repository/collection_repository.dart';

const List<PlayerStatus> _teamStatusPriority = [
  PlayerStatus.disqualified,
  PlayerStatus.injured,
  PlayerStatus.forfeited,
  PlayerStatus.notAttending,
  PlayerStatus.attending,
];

/// Returns the [PlayerStatus] of the [team].
///
/// When all team members have [PlayerStatus.attending] then that is also the
/// [team]'s status. Otherwise the highest priority status
/// (according to [_teamStatusPriority]) that one of the members has is returned.
PlayerStatus teamStatus(Team team) {
  List<PlayerStatus> teamStatusList =
      team.players.map((p) => p.status).toList();

  if (teamStatusList.length == 1) {
    return teamStatusList.first;
  }

  for (PlayerStatus teamStatus in _teamStatusPriority) {
    if (teamStatusList.contains(teamStatus)) {
      return teamStatus;
    }
  }

  // Wont be reached
  return PlayerStatus.attending;
}
