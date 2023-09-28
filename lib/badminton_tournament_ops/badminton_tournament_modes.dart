import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_round_robin_ranking.dart';
import 'package:tournament_mode/tournament_mode.dart';

BadmintonMatch _matcher(MatchParticipant<Team> a, MatchParticipant<Team> b) =>
    BadmintonMatch(a, b);

class BadmintonSingleElimination
    extends SingleElimination<Team, List<MatchSet>> {
  BadmintonSingleElimination({
    required super.seededEntries,
  }) : super(matcher: _matcher);
}

class BadmintonRoundRobin extends RoundRobin<Team, List<MatchSet>> {
  BadmintonRoundRobin({
    required super.entries,
    required RoundRobinSettings settings,
  }) : super(
          matcher: _matcher,
          finalRanking: BadmintonRoundRobinRanking(),
          passes: settings.passes,
        );
}

class BadmintonGroupKnockout extends GroupKnockout<Team, List<MatchSet>> {
  BadmintonGroupKnockout({
    required super.entries,
    required GroupKnockoutSettings settings,
  }) : super(
          matcher: _matcher,
          numGroups: settings.numGroups,
          qualificationsPerGroup: settings.qualificationsPerGroup,
          groupRankingBuilder: () => BadmintonRoundRobinRanking(),
        );
}
