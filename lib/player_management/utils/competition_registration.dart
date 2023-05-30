import 'package:collection_repository/collection_repository.dart';

/// Maps players to the competitions that they are registered for
Map<Player, List<Competition>> mapPlayerCompetitions(
  List<Player> players,
  List<Competition> competitions,
) {
  var playerCompetitions = {for (var p in players) p: <Competition>[]};
  for (var competition in competitions) {
    var teams = competition.registrations;
    var players = teams.expand((team) => team.players);
    for (var player in players) {
      playerCompetitions[player]?.add(competition);
    }
  }
  return playerCompetitions;
}
