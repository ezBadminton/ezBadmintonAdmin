import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/models/competition_registration.dart';

/// Maps players to [CompetitionRegistration]s containing the [Competition]s
/// that they are registered for.
Map<Player, List<CompetitionRegistration>> mapCompetitionRegistrations(
  List<Player> players,
  List<Competition> competitions,
) {
  var playerCompetitions = {
    for (Player p in players) p: <CompetitionRegistration>[],
  };
  for (Competition competition in competitions) {
    List<Team> teams = competition.registrations;
    Iterable<Player> players = teams.expand((team) => team.players);
    for (var player in players) {
      playerCompetitions[player]?.add(
        CompetitionRegistration.fromCompetition(
          competition: competition,
          player: player,
        ),
      );
    }
  }
  return playerCompetitions;
}

List<CompetitionRegistration> registrationsOfPlayer(
  Player player,
  List<Competition> competitions,
) {
  List<CompetitionRegistration> registrations = [];
  for (Competition competition in competitions) {
    List<Team> teams = competition.registrations;
    Iterable<Player> players = teams.expand((team) => team.players);
    if (players.contains(player)) {
      registrations.add(
        CompetitionRegistration.fromCompetition(
          competition: competition,
          player: player,
        ),
      );
    }
  }

  return registrations;
}
