import 'package:model_repository/model_repository.dart';

/// Maps players to [CompetitionRegistration]s containing the [Competition]s
/// that they are registered for.
Map<Player, List<Registration>> mapCompetitionRegistrations(
  List<Registration> registrations,
) {
  var playerRegs = <Player, List<Registration>>{};
  for (var reg in registrations) {
    for (var player in reg.team.players) {
      playerRegs.putIfAbsent(player, () => []);
      playerRegs[player]!.add(reg);
    }
  }
  return playerRegs;
}

List<Registration> registrationsOfPlayer(
  Player player,
  List<Registration> registrations,
) {
  var regsOfPlayer =
      registrations.where((r) => r.team.players.contains(player)).toList();
  return regsOfPlayer;
}
