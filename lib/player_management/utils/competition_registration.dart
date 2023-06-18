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

/// Creates a [registration] on the DB using [querier]. Returns the updated
/// [Competition] object on success.
///
/// The [CompetitionRegistration.team] object already has to contain the
/// [CompetitionRegistration.player] that is getting registered. If the player
/// is registered with a partner they also have to be in the team.
Future<Competition?> registerCompetition(
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
  if (_isPlayerAlreadyRegistered(player, team, competition)) {
    return null;
  }

  List<Team> updatedCompetitionRegistrations =
      List.of(competition.registrations)..remove(team);

  // Check if eventual partner already has a solo team and delete if so
  Team? teamOfPartner = registration.getPartnerTeam();
  if (teamOfPartner != null) {
    assert(
      teamOfPartner.players.length == 1,
      'Team partner is already partnered',
    );
    updatedCompetitionRegistrations.remove(teamOfPartner);
    bool partnerTeamDeleted = await querier.deleteModel(teamOfPartner);
    if (!partnerTeamDeleted) {
      return null;
    }
  }

  Team? updatedTeam = await querier.updateOrCreateModel(team);
  if (updatedTeam == null) {
    return null;
  }

  updatedCompetitionRegistrations.add(updatedTeam);
  Competition competitionWithUpdatedTeam = competition.copyWith(
    registrations: updatedCompetitionRegistrations,
  );
  Competition? updatedCompetition =
      await querier.updateModel(competitionWithUpdatedTeam);

  return updatedCompetition;
}

/// Remove a [registration] from the DB using the [querier]. Returns the updated
/// [Competition] object on success.
///
/// The [registration.player] will be removed from their [Team] and if the Team
/// has no members as a result it will also be removed.
Future<Competition?> deregisterCompetition(
  CompetitionRegistration registration,
  CollectionQuerier querier,
) async {
  Player player = registration.player;
  Team team = registration.team;
  assert(
    team.players.contains(player),
    'Cannot deregister Player from Team they are not a member of',
  );
  Competition competition = registration.competition;
  List<Team> updatedCompetitionRegistrations =
      List.of(competition.registrations)..remove(team);

  if (team.players.length == 1) {
    // remove team
    bool teamDeleted = await querier.deleteModel(team);
    if (!teamDeleted) {
      return null;
    }
  } else {
    // update team
    List<Player> teamMembers = List.of(team.players)..remove(player);
    Team teamWithoutPlayer = team.copyWith(players: teamMembers);
    Team? updatedTeam = await querier.updateModel(teamWithoutPlayer);
    if (updatedTeam == null) {
      return null;
    }
    updatedCompetitionRegistrations.add(updatedTeam);
  }

  Competition competitionWithUpdatedTeam = competition.copyWith(
    registrations: updatedCompetitionRegistrations,
  );
  Competition? updatedCompetition =
      await querier.updateModel(competitionWithUpdatedTeam);

  return updatedCompetition;
}

bool _isPlayerAlreadyRegistered(
  Player player,
  Team newTeam,
  Competition competition,
) {
  Team? registeredTeam = competition.registrations
      .where((team) => team.players.contains(player))
      .firstOrNull;
  return (registeredTeam != null && registeredTeam.id != newTeam.id);
}
