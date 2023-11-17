// Functions to instantiate and "hydrate" TournamentMode objects with
// seeding, drawing and match data.

import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:tournament_mode/tournament_mode.dart';

/// Create the [TournamentMode] from the [competition].
///
/// The  [Competition.tournamentModeSettings] and [Competition.draw] are used to
/// create the tournament mode.
BadmintonTournamentMode createTournamentMode(Competition competition) {
  assert(competition.tournamentModeSettings != null);
  assert(competition.draw.isNotEmpty);

  TournamentModeSettings settings = competition.tournamentModeSettings!;
  DrawSeeds<Team> entries = DrawSeeds(competition.draw);

  BadmintonTournamentMode tournament = switch (settings) {
    SingleEliminationSettings _ =>
      BadmintonSingleElimination(seededEntries: entries),
    RoundRobinSettings settings =>
      BadmintonRoundRobin.fromSettings(entries: entries, settings: settings),
    GroupKnockoutSettings settings =>
      BadmintonGroupKnockout.fromSettings(entries: entries, settings: settings),
  };

  return tournament;
}

/// Creates a new [MatchData] object for each [BadmintonMatch] in the
/// [tournamentMode].
List<MatchData> createMatchesFromTournament(
  BadmintonTournamentMode tournamentMode,
) {
  return tournamentMode.matches
      .where((match) => !match.isBye)
      .map((_) => MatchData.newMatch())
      .toList();
}

/// Hydrate the [tournamentMode]'s matches with the [matchDataList].
void hydrateTournament(
  Competition competition,
  BadmintonTournamentMode tournamentMode,
  List<MatchData> matchDataList,
) {
  List<BadmintonMatch> matches =
      tournamentMode.matches.where((match) => !match.isBye).toList();
  assert(matchDataList.length == matches.length);

  for (int i = 0; i < matchDataList.length; i += 1) {
    matches[i].hydrateMatch(competition, matchDataList[i]);
  }
}
