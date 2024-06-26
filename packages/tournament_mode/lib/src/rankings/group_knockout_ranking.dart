import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/modes/modes.dart';
import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/rankings/rankings.dart';
import 'package:tournament_mode/src/tournament_match.dart';
import 'package:tournament_mode/src/utils.dart';

class GroupKnockoutRanking<P, S, M extends TournamentMatch<P, S>>
    extends Ranking<P> with TieableRanking<P> {
  GroupKnockoutRanking({
    required this.groupKnockout,
  });

  final GroupKnockout<
      P,
      S,
      M,
      RoundRobin<P, S, M>,
      GroupPhase<P, S, M, RoundRobin<P, S, M>>,
      EliminationChain<P, S, M>> groupKnockout;

  @override
  List<List<MatchParticipant<P>>> createTiedRanks() {
    List<List<List<MatchParticipant<P>>>> groupRanks = groupKnockout
        .groupPhase.groupRoundRobins
        .map((r) => r.finalRanking.tiedRanks)
        .toList();

    int maxLength = groupRanks.fold(
      0,
      (maxLength, ranks) => ranks.length > maxLength ? ranks.length : maxLength,
    );

    List<List<MatchParticipant<P>>> combinedGroupRanks = List.generate(
      maxLength,
      (index) {
        List<MatchParticipant<P>> combinedRank = groupRanks
            .expand(
              (groupRank) =>
                  groupRank.elementAtOrNull(index) ?? <MatchParticipant<P>>[],
            )
            .toList();
        return combinedRank;
      },
    );

    List<List<MatchParticipant<P>>> knockOutRanks =
        groupKnockout.knockoutPhase.finalRanking.tiedRanks;

    List<List<MatchParticipant<P>>> overallRanks = [
      ...knockOutRanks,
      ...combinedGroupRanks,
    ];

    overallRanks = filterHighestRanks(overallRanks);

    return overallRanks;
  }
}
