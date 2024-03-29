import 'package:collection/collection.dart';
import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/modes/group_phase.dart';
import 'package:tournament_mode/src/modes/round_robin.dart';
import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/rankings/match_ranking.dart';
import 'package:tournament_mode/src/tournament_match.dart';

/// The ranking of a [GroupPhase].
///
/// For `n` groups the first `n` ranks are the participants who finished first
/// in each group, the next `n` ranks are the second place finishers, etc...
///
/// If `m` groups have less members then the last place is a block of
/// only `n-m` participants.
class GroupPhaseRanking<P, S, M extends TournamentMatch<P, S>>
    extends Ranking<P> {
  /// Creates a [GroupPhaseRanking] for the [groups].
  GroupPhaseRanking(
    this.groupPhase,
  );

  final GroupPhase<P, S, M, RoundRobin<P, S, M>> groupPhase;
  List<RoundRobin<P, S, M>> get groups => groupPhase.groupRoundRobins;

  @override
  List<MatchParticipant<P>> createRanks() {
    int crossRankedRank = _getCrossRankedRank();

    List<List<MatchParticipant<P>>> groupRankings =
        groups.map((g) => _getGroupRanking(g, crossRankedRank)).toList();

    int maxLength = groupRankings.map((r) => r.length).max;

    List<MatchParticipant<P>> ranks = [];
    for (int i = 0; i < maxLength; i += 1) {
      List<MatchParticipant<P>> groupRank = [
        for (List<MatchParticipant<P>> groupRanking
            in groupRankings.where((r) => i < r.length))
          groupRanking[i],
      ];

      if (i == crossRankedRank) {
        groupRank = _crossRank(groupRank);
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
  List<MatchParticipant<P>> _crossRank(List<MatchParticipant<P>> participants) {
    List<MatchParticipant<P>> crossGroupRanks =
        groupPhase.crossGroupRanking.ranks;

    List<MatchParticipant<P>> crossRanks = participants.sortedBy<num>(
      (p) => crossGroupRanks.indexWhere(
        (groupParticipant) =>
            p.resolvePlayer() == groupParticipant.resolvePlayer(),
      ),
    );

    return crossRanks;
  }
}

/// A [Placement] for a [TieableMatchRanking].
///
/// It holds back the placement ([getPlacement] returns null) while the matches
/// are not all completed or while there is an unbroken tie.
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
  }) : super(ranking: ranking);

  final int group;

  /// [isCrossGroup] is true when the placement is dependent on a cross
  /// group ranking.
  final bool isCrossGroup;

  @override
  TieableMatchRanking<P, dynamic, TournamentMatch<P, dynamic>> get ranking =>
      super.ranking
          as TieableMatchRanking<P, dynamic, TournamentMatch<P, dynamic>>;

  @override
  MatchParticipant<P>? getPlacement() {
    if (!ranking.allMatchesComplete()) {
      return null;
    }

    MatchParticipant<P>? placement = super.getPlacement();

    P? player = placement?.resolvePlayer();

    Iterable<P> tiedPlayers = ranking.ties
        .expand((tie) => tie.map((participant) => participant.resolvePlayer()))
        .whereType<P>();

    if (tiedPlayers.contains(player)) {
      return null;
    }

    if (player != null && _getWithdrawnPlayers().contains(player)) {
      return MatchParticipant<P>.bye();
    }

    return placement;
  }

  Set<P> _getWithdrawnPlayers() {
    if (ranking.matches == null) {
      return {};
    }

    return ranking.matches!
        .expand<MatchParticipant<P>>(
            (match) => match.withdrawnParticipants ?? [])
        .map((participant) => participant.resolvePlayer())
        .whereType<P>()
        .toSet();
  }
}
