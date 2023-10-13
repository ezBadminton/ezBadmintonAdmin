import 'package:tournament_mode/src/modes/chained_tournament_mode.dart';
import 'package:tournament_mode/src/modes/group_phase.dart';
import 'package:tournament_mode/src/modes/round_robin.dart';
import 'package:tournament_mode/src/modes/single_elimination.dart';
import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/rankings/group_phase_ranking.dart';
import 'package:tournament_mode/src/rankings/group_qualification_ranking.dart';
import 'package:tournament_mode/src/tournament_match.dart';

/// A [GroupPhase] followed by a knockout-phase ([SingleElimination])
class GroupKnockout<
        P,
        S,
        M extends TournamentMatch<P, S>,
        R extends RoundRobin<P, S, M>,
        G extends GroupPhase<P, S, M, R>,
        E extends SingleElimination<P, S, M>>
    extends ChainedTournamentMode<P, S, M, G, E> {
  GroupKnockout({
    required Ranking<P> entries,
    required this.numGroups,
    required this.qualificationsPerGroup,
    required G Function(
      Ranking<P> entries,
      int numGroups,
    ) groupPhaseBuilder,
    required E Function(
      Ranking<P> seededEntries,
    ) singleEliminationBuilder,
  }) : super(
          entries: entries,
          firstBuilder: (Ranking<P> entries) => groupPhaseBuilder(
            entries,
            numGroups,
          ),
          secondBuilder: (Ranking<P> entries) => singleEliminationBuilder(
            entries,
          ),
          rankingTransition: (Ranking<P> groupResults) =>
              GroupQualificationRanking(
            groupResults as GroupPhaseRanking<P, S, M>,
            numGroups: numGroups,
            qualificationsPerGroup: qualificationsPerGroup,
          ),
        );

  final int numGroups;
  final int qualificationsPerGroup;

  G get groupPhase => super.first;

  E get knockoutPhase => super.second;
}
