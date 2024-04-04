import 'package:collection/collection.dart';
import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/modes/group_phase.dart';
import 'package:tournament_mode/src/modes/round_robin.dart';
import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/rankings/rankings.dart';
import 'package:tournament_mode/src/tournament_match.dart';

/// The ranking of a [GroupPhase].
///
/// For `n` groups the first `n` ranks are the participants who finished first
/// in each group, the next `n` ranks are the second place finishers, etc...
///
/// If `m` groups have less members then the last place is a block of
/// only `n-m` participants.
class GroupPhaseRanking<P, S, M extends TournamentMatch<P, S>>
    extends Ranking<P> with TieableRanking<P> {
  /// Creates a [GroupPhaseRanking] for the [groups].
  GroupPhaseRanking(
    this.groupPhase,
  ) {
    requiredUntiedRanks = groupPhase.numQualifications;
  }

  final GroupPhase<P, S, M, RoundRobin<P, S, M>> groupPhase;
  List<RoundRobin<P, S, M>> get groups => groupPhase.groupRoundRobins;

  @override
  List<List<MatchParticipant<P>>> createTiedRanks() {
    int crossRankedRank = _getCrossRankedRank();

    List<List<MatchParticipant<P>>> groupRankings =
        groups.map((g) => _getGroupRanking(g, crossRankedRank)).toList();

    int maxLength = groupRankings.map((r) => r.length).max;

    List<List<MatchParticipant<P>>> ranks = [];
    for (int i = 0; i < maxLength; i += 1) {
      List<List<MatchParticipant<P>>> groupRank = [
        for (List<MatchParticipant<P>> groupRanking
            in groupRankings.where((r) => i < r.length))
          [groupRanking[i]],
      ];

      if (i == crossRankedRank) {
        groupRank = _crossRank(groupRank.flattened.toList());
      }

      ranks.addAll(groupRank);
    }

    return ranks;
  }

  List<MatchParticipant<P>> _getGroupRanking(
    RoundRobin<P, S, M> group,
    int crossRankedRank,
  ) {
    int groupSize = group.participants.where((p) => !p.isBye).length;
    int groupIndex = groupPhase.groupRoundRobins.indexOf(group);

    return List.generate(
      groupSize,
      (place) => MatchParticipant.fromPlacement(
        GroupPhasePlacement(
          ranking: group.finalRanking,
          place: place,
          group: groupIndex,
          isCrossGroup: place == crossRankedRank,
          groupPhase: groupPhase,
        ),
      ),
    );
  }

  /// When the number of qualifications is not divisible by the number
  /// of groups, the occupants of one rank have to be compared across all
  /// groups to determine who qualifies. This method returns the rank
  /// where the cross comparison has to take place.
  /// Returns -1 if the qualifications are divisible and no cross comparison
  /// is needed.
  int _getCrossRankedRank() {
    if (groupPhase.numQualifications % groupPhase.numGroups == 0) {
      return -1;
    }

    return groupPhase.numQualifications ~/ groupPhase.numGroups;
  }

  /// Order the given [participants] by their ranks in the overall cross group
  /// ranking.
  List<List<MatchParticipant<P>>> _crossRank(
    List<MatchParticipant<P>> participants,
  ) {
    Iterable<P?> players = participants.map((p) => p.player);

    if (players.contains(null)) {
      return participants.map((p) => [p]).toList();
    }

    List<List<MatchParticipant<P>>> crossGroupRanks =
        groupPhase.crossGroupRanking.tiedRanks;

    List<List<MatchParticipant<P>>> referenceRanks = crossGroupRanks
        .map(
          (rank) => rank.where((p) => players.contains(p.player)).toList(),
        )
        .where((rank) => rank.isNotEmpty)
        .toList();

    List<List<MatchParticipant<P>>> crossRanks = referenceRanks
        .map(
          (rank) => rank
              .map(
                (reference) => participants
                    .firstWhere((p) => reference.player == p.player),
              )
              .toList(),
        )
        .toList();

    return crossRanks;
  }
}

/// A [Placement] for a [TieableMatchRanking].
///
/// It holds back the placement ([getPlacement] returns null) while the group
/// phase matches are not all completed or while there is an unbroken tie.
///
/// It also replaces any placed participants that withdrew from the matches with
/// a [MatchParticipant.bye]. This way no withdrawn players can pass this
/// placement.
///
/// For example it can happen that 3 of 4 group members withdraw but the top 2
/// qualify for the knockouts. Then 2nd place is occupied by a withdrawn player.
/// The [GroupPhasePlacement] prevents this player from going to the next
/// round, instead giving the would be opponent of the 2nd place a bye round.
class GroupPhasePlacement<P> extends Placement<P> {
  GroupPhasePlacement({
    required TieableMatchRanking<P, dynamic, TournamentMatch<P, dynamic>>
        ranking,
    required super.place,
    required this.group,
    required this.isCrossGroup,
    required this.groupPhase,
  }) : super(ranking: ranking);

  final int group;

  /// [isCrossGroup] is true when the placement is dependent on a cross
  /// group ranking.
  final bool isCrossGroup;

  final GroupPhase groupPhase;
  TieableRanking get groupPhaseRanking => groupPhase.finalRanking;

  @override
  TieableMatchRanking<P, dynamic, TournamentMatch<P, dynamic>> get ranking =>
      super.ranking
          as TieableMatchRanking<P, dynamic, TournamentMatch<P, dynamic>>;

  @override
  MatchParticipant<P>? getPlacement() {
    if (!groupPhase.isCompleted() ||
        _doGroupsHaveTie() ||
        groupPhaseRanking.blockingTies.isNotEmpty) {
      return null;
    }

    MatchParticipant<P>? placement = super.getPlacement();
    P? player = placement?.player;

    if (_isPlayerWithdrawn(player)) {
      return MatchParticipant<P>.bye();
    }

    return placement;
  }

  /// Returns the placement like a normal [Placement] bypassing the blocking
  /// conditions from the group phase.
  MatchParticipant<P>? getUnblockedPlacement() {
    return super.getPlacement();
  }

  bool _isPlayerWithdrawn(P? player) {
    if (ranking.matches == null || player == null) {
      return false;
    }

    return ranking.matches!.firstWhereOrNull(
          (m) => (m.withdrawnParticipants ?? [])
              .map((p) => p.player)
              .contains(player),
        ) !=
        null;
  }

  /// Returns wether at least one group has a tie in its internal final ranking
  bool _doGroupsHaveTie() {
    return groupPhase.groupRoundRobins
            .firstWhereOrNull((g) => g.finalRanking.blockingTies.isNotEmpty) !=
        null;
  }
}
