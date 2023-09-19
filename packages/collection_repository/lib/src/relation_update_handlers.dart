import 'package:collection_repository/collection_repository.dart';

// Updates the cached competitions when their PlayingLevel is updated
List<Competition> onCompetitionRelationUpdate(
  List<Competition> competitions,
  CollectionUpdateEvent updateEvent,
) {
  if (updateEvent.model is PlayingLevel &&
      updateEvent.updateType == UpdateType.update) {
    PlayingLevel updatedPlayingLevel = updateEvent.model as PlayingLevel;

    return competitions
        .where((c) => c.playingLevel == updatedPlayingLevel)
        .map((c) => c.copyWith(playingLevel: updatedPlayingLevel))
        .toList();
  }

  if (updateEvent.model is Team &&
      updateEvent.updateType == UpdateType.update) {
    Team updatedTeam = updateEvent.model as Team;

    List<Competition> containingCompetitions = competitions
        .where((c) => c.registrations.contains(updatedTeam))
        .toList();

    List<Competition> updatedCompetitions = [];

    for (Competition competition in containingCompetitions) {
      List<Team> registrations = List.of(competition.registrations);

      registrations.removeWhere((t) => t.id == updatedTeam.id);
      registrations.add(updatedTeam);

      updatedCompetitions.add(
        competition.copyWith(registrations: registrations),
      );
    }

    return updatedCompetitions;
  }

  return [];
}

List<Team> onTeamRelationUpdate(
  List<Team> teams,
  CollectionUpdateEvent updateEvent,
) {
  if (updateEvent.model is Player &&
      updateEvent.updateType == UpdateType.update) {
    Player updatedPlayer = updateEvent.model as Player;

    List<Team> containingTeams = teams
        .where(
          (t) => t.players.contains(updatedPlayer),
        )
        .toList();

    List<Team> updatedTeams = [];
    for (Team team in containingTeams) {
      List<Player> players = List.of(team.players);
      players.removeWhere((p) => p.id == updatedPlayer.id);
      players.add(updatedPlayer);

      updatedTeams.add(team.copyWith(players: players));
    }

    return updatedTeams;
  }

  return [];
}
