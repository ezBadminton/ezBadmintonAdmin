import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/modes/chained_tournament_mode.dart';
import 'package:tournament_mode/src/modes/group_phase.dart';
import 'package:tournament_mode/src/modes/single_elimination.dart';
import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/rankings/group_qualifiaction_ranking.dart';
import 'package:tournament_mode/src/rankings/match_ranking.dart';
import 'package:tournament_mode/src/tournament_match.dart';

/// A [GroupPhase] followed by a knockout-phase ([SingleElimination])
class GroupKnockout<P, S> extends ChainedTournamentMode<P, S> {
  GroupKnockout({
    required Ranking<P> entries,
    required int numGroups,
    required int qualificationsPerGroup,
    required MatchRanking<P, S> Function() groupRankingBuilder,
    required TournamentMatch<P, S> Function(
      MatchParticipant<P> a,
      MatchParticipant<P> b,
    ) matcher,
  }) : super(
          entries: entries,
          firstBuilder: (Ranking<P> entries) => GroupPhase(
            entries: entries,
            numGroups: numGroups,
            rankingBuilder: groupRankingBuilder,
            matcher: matcher,
          ),
          secondBuilder: (Ranking<P> entries) => SingleElimination(
            seededEntries: entries,
            matcher: matcher,
          ),
          rankingTransition: (Ranking<P> groupResults) =>
              GroupQualificationRanking(
            groupResults,
            numGroups: numGroups,
            qualificationsPerGroup: qualificationsPerGroup,
          ),
        );

  GroupPhase<P, S> get groupPhase => super.first as GroupPhase<P, S>;

  SingleElimination<P, S> get knockoutPhase =>
      super.second as SingleElimination<P, S>;
}
