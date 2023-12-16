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
    SingleEliminationSettings _ => BadmintonSingleElimination(
        seededEntries: entries,
        competition: competition,
      ),
    RoundRobinSettings _ => BadmintonRoundRobin.fromCompetition(
        entries: entries,
        competition: competition,
      ),
    GroupKnockoutSettings _ => BadmintonGroupKnockout.fromCompetition(
        entries: entries,
        competition: competition,
      ),
    DoubleEliminationSettings _ => BadmintonDoubleElimination(
        seededEntries: entries,
        competition: competition,
      ),
  };

  return tournament;
}

/// Creates a new [MatchData] object for each [BadmintonMatch] in the
/// [tournamentMode].
List<MatchData> createMatchesFromTournament(
  BadmintonTournamentMode tournamentMode,
) {
  return tournamentMode.matches
      .where((match) => !match.isDrawnBye)
      .map((_) => MatchData.newMatch())
      .toList();
}

/// Hydrate the [tournamentMode]'s matches with the [matchDataList].
void hydrateTournament(
  Competition competition,
  BadmintonTournamentMode tournamentMode,
  List<MatchData>? matchDataList,
) {
  List<BadmintonMatch> matches =
      tournamentMode.matches.where((match) => !match.isDrawnBye).toList();
  assert(matchDataList == null || matchDataList.length == matches.length);

  _applyTieBreakers(competition, tournamentMode);

  for (int i = 0; i < matches.length; i += 1) {
    matches[i].hydrateMatch(competition, matchDataList?[i]);
  }

  // The drawn bye matches do not have match data
  Iterable<BadmintonMatch> byes =
      tournamentMode.matches.where((match) => match.isDrawnBye);

  for (BadmintonMatch match in byes) {
    match.hydrateMatch(competition, null);
  }
}

void _applyTieBreakers(
  Competition competition,
  BadmintonTournamentMode tournamentMode,
) {
  if (competition.tieBreakers.isEmpty) {
    return;
  }

  List<Ranking<Team>> tieBreakerRankings = competition.tieBreakers
      .map((tieBreaker) => DrawSeeds<Team>(tieBreaker.tieBreakerRanking))
      .toList();

  switch (tournamentMode) {
    case BadmintonRoundRobin roundRobin:
      roundRobin.finalRanking.tieBreakers = tieBreakerRankings;
      break;
    case BadmintonGroupKnockout groupKnockout:
      for (BadmintonRoundRobin group
          in groupKnockout.groupPhase.groupRoundRobins) {
        group.finalRanking.tieBreakers = tieBreakerRankings;
      }
      break;
  }
}
