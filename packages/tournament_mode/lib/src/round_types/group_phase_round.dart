import 'package:collection/collection.dart';
import 'package:tournament_mode/src/modes/round_robin.dart';
import 'package:tournament_mode/src/round_types/round_robin_round.dart';
import 'package:tournament_mode/src/tournament_match.dart';

class GroupPhaseRound<M extends TournamentMatch> extends RoundRobinRound<M> {
  GroupPhaseRound({
    required List<RoundRobin<dynamic, dynamic, M>> groupRoundRobins,
    required super.roundNumber,
    required super.totalRounds,
  }) : super(
          matches: _intertwineGroupRound(groupRoundRobins, roundNumber),
          nestedRounds: _getGroupRounds(groupRoundRobins, roundNumber),
        );

  @override
  List<RoundRobinRound<M>> get nestedRounds =>
      super.nestedRounds as List<RoundRobinRound<M>>;

  /// Returns a list of matches that contains all the matches of the [round]
  /// inside the [groups].
  ///
  /// The matches are ordered such that the first match of each group comes
  /// first, then all the second matches and so on.
  static List<M> _intertwineGroupRound<M extends TournamentMatch>(
    List<RoundRobin<dynamic, dynamic, M>> groups,
    int round,
  ) {
    List<RoundRobinRound<M>> groupRounds = _getGroupRounds(groups, round);

    int maxLength = groupRounds.map((round) => round.length).max;

    List<M> groupRound = [
      for (int i = 0; i < maxLength; i += 1)
        ...groupRounds
            .where((round) => i < round.length)
            .map((round) => round.matches[i]),
    ];

    return groupRound;
  }

  /// Returns the [RoundRobinRound] with the given [round] number from each of
  /// the [groups] in a list. If some of the groups don't have rounds up to that
  /// round number, they are skipped.
  static List<RoundRobinRound<M>> _getGroupRounds<M extends TournamentMatch>(
    List<RoundRobin<dynamic, dynamic, M>> groups,
    int round,
  ) {
    List<RoundRobinRound<M>> groupRounds = groups
        .where((roundRobin) => round < roundRobin.rounds.length)
        .map((roundRobin) => roundRobin.rounds[round])
        .toList();

    return groupRounds;
  }
}
