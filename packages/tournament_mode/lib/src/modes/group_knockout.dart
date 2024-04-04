import 'package:tournament_mode/src/modes/chained_tournament_mode.dart';
import 'package:tournament_mode/src/modes/group_phase.dart';
import 'package:tournament_mode/src/modes/qualification_chain.dart';
import 'package:tournament_mode/src/modes/round_robin.dart';
import 'package:tournament_mode/src/modes/single_elimination.dart';
import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/rankings/passthrough_ranking.dart';
import 'package:tournament_mode/src/rankings/rankings.dart';
import 'package:tournament_mode/src/tournament_match.dart';

/// A [GroupPhase] followed by a knockout-phase ([SingleElimination])
class GroupKnockout<
        P,
        S,
        M extends TournamentMatch<P, S>,
        R extends RoundRobin<P, S, M>,
        G extends GroupPhase<P, S, M, R>,
        E extends EliminationChain<P, S, M>>
    extends ChainedTournamentMode<P, S, M, G, E> {
  GroupKnockout({
    required Ranking<P> entries,
    required this.numGroups,
    required this.numQualifications,
    required G Function(
      Ranking<P> entries,
      int numGroups,
    ) groupPhaseBuilder,
    required E Function(
      Ranking<P> seededEntries,
    ) eliminationBuilder,
  }) : super(
          entries: entries,
          firstBuilder: (Ranking<P> entries) => groupPhaseBuilder(
            entries,
            numGroups,
          ),
          secondBuilder: eliminationBuilder,
          rankingTransition: (Ranking<P> groupResults) {
            PassthroughRanking<P> transition = PassthroughRanking(
              GroupQualificationRanking(
                groupResults as GroupPhaseRanking<P, S, M>,
                numGroups: numGroups,
                numQualifications: numQualifications,
              ),
            );

            groupResults.addDependantRanking(transition);

            return transition;
          },
        ) {
    _finalRanking = GroupKnockoutRanking(groupKnockout: this);
  }

  final int numGroups;
  final int numQualifications;

  late final TieableRanking<P> _finalRanking;

  @override
  Ranking<P> get finalRanking => _finalRanking;

  G get groupPhase => super.first;

  E get knockoutPhase => super.second;
}
