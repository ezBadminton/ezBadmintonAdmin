import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_round_robin_ranking.dart';
import 'package:tournament_mode/tournament_mode.dart';

BadmintonMatch _matcher(MatchParticipant<Team> a, MatchParticipant<Team> b) =>
    BadmintonMatch(a, b);

typedef BadmintonTournamentMode
    = TournamentMode<Team, List<MatchSet>, BadmintonMatch>;

typedef BadmintonTournamentRound = TournamentRound<BadmintonMatch>;

class BadmintonSingleElimination
    extends SingleElimination<Team, List<MatchSet>, BadmintonMatch> {
  BadmintonSingleElimination({
    required super.seededEntries,
  }) : super(matcher: _matcher);
}

class BadmintonRoundRobin
    extends RoundRobin<Team, List<MatchSet>, BadmintonMatch> {
  BadmintonRoundRobin({
    required super.entries,
    required super.passes,
  }) : super(
          matcher: _matcher,
          finalRanking: BadmintonRoundRobinRanking(),
        );

  BadmintonRoundRobin.fromSettings({
    required super.entries,
    required RoundRobinSettings settings,
  }) : super(
          matcher: _matcher,
          finalRanking: BadmintonRoundRobinRanking(),
          passes: settings.passes,
        );
}

class BadmintonGroupPhase extends GroupPhase<Team, List<MatchSet>,
    BadmintonMatch, BadmintonRoundRobin> {
  BadmintonGroupPhase({
    required super.entries,
    required super.numGroups,
  }) : super(
          roundRobinBuilder: (entries) => BadmintonRoundRobin(
            entries: entries,
            passes: 1,
          ),
        );
}

class BadmintonGroupKnockout extends GroupKnockout<
    Team,
    List<MatchSet>,
    BadmintonMatch,
    BadmintonRoundRobin,
    BadmintonGroupPhase,
    BadmintonSingleElimination> {
  BadmintonGroupKnockout({
    required super.entries,
    required super.numGroups,
    required super.qualificationsPerGroup,
  }) : super(
          groupPhaseBuilder: (entries, numGroups) => BadmintonGroupPhase(
            entries: entries,
            numGroups: numGroups,
          ),
          singleEliminationBuilder: (seededEntries) =>
              BadmintonSingleElimination(
            seededEntries: seededEntries,
          ),
        );

  BadmintonGroupKnockout.fromSettings({
    required super.entries,
    required GroupKnockoutSettings settings,
  }) : super(
          numGroups: settings.numGroups,
          qualificationsPerGroup: settings.qualificationsPerGroup,
          groupPhaseBuilder: (entries, numGroups) => BadmintonGroupPhase(
            entries: entries,
            numGroups: numGroups,
          ),
          singleEliminationBuilder: (seededEntries) =>
              BadmintonSingleElimination(
            seededEntries: seededEntries,
          ),
        );
}
