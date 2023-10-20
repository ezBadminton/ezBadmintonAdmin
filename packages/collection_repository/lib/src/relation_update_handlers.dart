import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';

/// Updates the cached competitions when their [PlayingLevel] or a [Team] that
/// is registered or the [MatchData] of a match is updated.
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

  if (updateEvent.model is Team) {
    Team updatedTeam = updateEvent.model as Team;

    Team? replacement = _getReplacement(updatedTeam, updateEvent);

    List<Competition> containingCompetitions = competitions
        .where((c) => c.registrations.contains(updatedTeam))
        .toList();

    List<Competition> updatedCompetitions = [];

    for (Competition competition in containingCompetitions) {
      List<Team> registrations = List.of(competition.registrations);
      List<Team> seeds = List.of(competition.seeds);
      List<Team> draw = List.of(competition.draw);

      replaceInList(registrations, updatedTeam.id, replacement);
      replaceInList(seeds, updatedTeam.id, replacement);
      replaceInList(draw, updatedTeam.id, replacement);

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

  if (updateEvent.model is MatchData) {
    MatchData updatedMatchData = updateEvent.model as MatchData;

    MatchData? replacement = _getReplacement(updatedMatchData, updateEvent);

    List<Competition> containingCompetitions = competitions
        .where((c) => c.matches.contains(updatedMatchData))
        .toList();

    List<Competition> updatedCompetitions = [];

    for (Competition competition in containingCompetitions) {
      List<MatchData> matches = List.of(competition.matches);

      replaceInList(matches, updatedMatchData.id, replacement);

      updatedCompetitions.add(competition.copyWith(matches: matches));
    }

    return updatedCompetitions;
  }

  return [];
}

List<Team> onTeamRelationUpdate(
  List<Team> teams,
  CollectionUpdateEvent updateEvent,
) {
  if (updateEvent.model is Player) {
    Player updatedPlayer = updateEvent.model as Player;

    Player? replacement = _getReplacement(updatedPlayer, updateEvent);

    List<Team> containingTeams =
        teams.where((t) => t.players.contains(updatedPlayer)).toList();

    List<Team> updatedTeams = [];
    for (Team team in containingTeams) {
      List<Player> players = List.of(team.players);
      replaceInList(players, updatedPlayer.id, replacement);

      updatedTeams.add(team.copyWith(players: players));
    }

    return updatedTeams;
  }

  return [];
}

List<MatchData> onMatchDataRelationUpdate(
  List<MatchData> matchData,
  CollectionUpdateEvent updateEvent,
) {
  if (updateEvent.model is Court) {
    Court updatedCourt = updateEvent.model as Court;

    Court? replacement = _getReplacement(updatedCourt, updateEvent);

    List<MatchData> containingMatchData =
        matchData.where((m) => m.court == updatedCourt).toList();

    List<MatchData> updatedMatchData =
        containingMatchData.map((m) => m.copyWith(court: replacement)).toList();

    return updatedMatchData;
  }

  if (updateEvent.model is MatchSet) {
    MatchSet updatedSet = updateEvent.model as MatchSet;

    MatchSet? replacement = _getReplacement(updatedSet, updateEvent);

    MatchData? containingMatchData =
        matchData.firstWhereOrNull((m) => m.sets.contains(updatedSet));

    if (containingMatchData != null) {
      List<MatchSet> sets = List.of(containingMatchData.sets);

      replaceInList(sets, updatedSet.id, replacement);

      return [containingMatchData.copyWith(sets: sets)];
    }
  }

  return [];
}

List<Court> onCourtRelationUpdate(
  List<Court> courts,
  CollectionUpdateEvent updateEvent,
) {
  if (updateEvent.model is Gymnasium &&
      updateEvent.updateType == UpdateType.update) {
    Gymnasium updatedGymnasium = updateEvent.model as Gymnasium;

    List<Court> containingCourts =
        courts.where((c) => c.gymnasium == updatedGymnasium).toList();

    List<Court> updatedCourts = containingCourts
        .map((c) => c.copyWith(gymnasium: updatedGymnasium))
        .toList();

    return updatedCourts;
  }

  return [];
}

/// In the [list], replaces the [Model] with the [id] with the [replacement].
///
/// When [replacement] is null, it just removes the [Model] with [id].
/// Does nothing if the [list] does not contain a model with the [id].
void replaceInList(List<Model> list, String id, Model? replacement) {
  int index = list.indexWhere((m) => m.id == id);
  if (index >= 0) {
    if (replacement == null) {
      list.removeAt(index);
    } else {
      list[index] = replacement;
    }
  }
}

T? _getReplacement<T>(T original, CollectionUpdateEvent updateEvent) {
  return switch (updateEvent.updateType) {
    UpdateType.delete => null,
    _ => original,
  };
}
