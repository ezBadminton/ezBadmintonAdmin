import 'package:collection/collection.dart';
import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/modes/group_phase.dart';
import 'package:tournament_mode/src/modes/round_robin.dart';
import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/tournament_match.dart';

/// The ranking of a [GroupPhase].
///
/// For `n` groups the first `n` ranks are the participants who finished first
/// in each group, the next `n` ranks are the second place finishers, etc...
///
/// If `m` groups have less members then the last place is a block of
/// only `n-m` participants.
class GroupPhaseRanking<P, S, M extends TournamentMatch<P, S>>
    implements Ranking<P> {
  /// Creates a [GroupPhaseRanking] for the [groups].
  GroupPhaseRanking(this.groups) {
    _createRanks();
  }

  final List<RoundRobin<P, S, M>> groups;

  List<MatchParticipant<P>>? _ranks;

  @override
  List<MatchParticipant<P>> rank() => _ranks!;

  void _createRanks() {
    List<List<MatchParticipant<P>>> groupRankings =
        groups.map(_getGroupRanking).toList();

    int maxLength = groupRankings.map((r) => r.length).max;

    _ranks = [
      for (int i = 0; i < maxLength; i += 1)
        for (List<MatchParticipant<P>> groupRanking
            in groupRankings.where((r) => i < r.length))
          groupRanking[i],
    ];
  }

  List<MatchParticipant<P>> _getGroupRanking(RoundRobin<P, S, M> group) {
    int groupSize = group.participants.where((p) => !p.isBye).length;
    return List.generate(
      groupSize,
      (place) => MatchParticipant.fromPlacement(
        Placement(ranking: group.finalRanking, place: place),
      ),
    );
  }
}
