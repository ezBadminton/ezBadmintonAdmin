import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/draw_management/models/badminton_match.dart';
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
    required super.finalRanking,
  }) : super(matcher: _matcher);
}

class BadmintonGroupKnockout extends GroupKnockout<Team, List<MatchSet>> {
  BadmintonGroupKnockout({
    required super.entries,
    required super.numGroups,
    required super.qualificationsPerGroup,
    required super.groupRankingBuilder,
  }) : super(matcher: _matcher);
}
