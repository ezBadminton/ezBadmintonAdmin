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
      List<Team> seeds = List.of(competition.seeds);
      List<Team> draw = List.of(competition.draw);

      _replaceInList(registrations, updatedTeam.id, updatedTeam);
      _replaceInList(seeds, updatedTeam.id, updatedTeam);
      _replaceInList(draw, updatedTeam.id, updatedTeam);

      updatedCompetitions.add(
        competition.copyWith(
          registrations: registrations,
          seeds: seeds,
          draw: draw,
        ),
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

    List<Team> containingTeams =
        teams.where((t) => t.players.contains(updatedPlayer)).toList();

    List<Team> updatedTeams = [];
    for (Team team in containingTeams) {
      List<Player> players = List.of(team.players);
      _replaceInList(players, updatedPlayer.id, updatedPlayer);

      updatedTeams.add(team.copyWith(players: players));
    }

    return updatedTeams;
  }

  return [];
}

/// In the [list], replaces the [Model] with the [id] with the [replacement].
///
/// Does nothing if the [list] does not contain a model with the [id].
void _replaceInList(List<Model> list, String id, Model replacement) {
  int index = list.indexWhere((m) => m.id == id);
  if (index >= 0) {
    list[index] = replacement;
  }
}
