import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/models/competition_registration.dart';

/// Maps players to [CompetitionRegistration]s containing the [Competition]s
/// that they are registered for.
Map<Player, List<CompetitionRegistration>> mapCompetitionRegistrations(
  List<Player> players,
  List<Competition> competitions,
) {
  var playerCompetitions = {
    for (var p in players) p: <CompetitionRegistration>[],
  };
  for (var competition in competitions) {
    var teams = competition.registrations;
    var players = teams.expand((team) => team.players);
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
