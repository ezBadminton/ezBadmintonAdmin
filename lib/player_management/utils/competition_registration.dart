import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
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

/// Creates a [registration] on the DB by creating a [Team].
/// Returns true on success.
///
/// The [CompetitionRegistration.team] object already has to contain the
/// [CompetitionRegistration.player] that is getting registered. If the player
/// is registered with a partner they also have to be in the team.
Future<bool> registerCompetition(
  CompetitionRegistration registration,
  CollectionQuerier querier,
) async {
  Player player = registration.player;
  Team team = registration.team;
  Competition competition = registration.competition;
  assert(
    team.players.contains(player),
    'Registered team does not contain registered player',
  );
  assert(
    team.players.length <= competition.teamSize,
    'The Team is already full',
  );

  Map<String, String> competitionQueryParam = {
    "competition": competition.id,
  };

  Team? updatedTeam = await querier.updateOrCreateModel(
    team,
    query: competitionQueryParam,
  );
  if (updatedTeam == null) {
    return false;
  }

  return true;
}

/// Remove a [registration] from the DB using the [querier].
/// Returns true on success.
///
/// The [registration.player] will be removed from their [Team] and if the Team
/// has no members as a result it will also be removed.
Future<bool> deregisterCompetition(
  CompetitionRegistration registration,
  CollectionQuerier querier,
) async {
  Player player = registration.player;
  Team team = registration.team;
  assert(
    team.players.contains(player),
    'Cannot deregister Player from Team they are not a member of',
  );

  // Update team. Team gets implicitly deleted server-side when the teamMembers are empty.
  List<Player> teamMembers = List.of(team.players)..remove(player);
  Team teamWithoutPlayer = team.copyWith(players: teamMembers);
  Team? updatedTeam = await querier.updateModel(teamWithoutPlayer);
  if (updatedTeam == null) {
    return false;
  }

  return true;
}
