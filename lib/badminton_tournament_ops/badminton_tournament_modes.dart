import 'package:collection/collection.dart';
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
    required Ranking<Team> entries,
    required RoundRobinSettings settings,
  }) : this(
          entries: entries,
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
    required Ranking<Team> entries,
    required GroupKnockoutSettings settings,
  }) : this(
          entries: entries,
          numGroups: settings.numGroups,
          qualificationsPerGroup: settings.qualificationsPerGroup,
        );

  @override
  List<BadmintonMatch> withdrawPlayer(Team player) {
    bool hasKnockOutStarted = knockoutPhase.matches.firstWhereOrNull(
          (m) => m.matchData!.startTime != null,
        ) !=
        null;

    // While the knock out phase has not started yet, the group walkovers are
    // forced even if the group matches have been completed.
    if (!hasKnockOutStarted) {
      return groupPhase.withdrawPlayer(player, true);
    } else {
      return knockoutPhase.withdrawPlayer(player);
    }
  }
}
