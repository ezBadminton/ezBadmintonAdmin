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
  GroupPhaseRanking(this.groups) {
    _createRanks();
  }

  final List<RoundRobin<P, S, M>> groups;

  List<MatchParticipant<P>>? _ranks;

  @override
  List<MatchParticipant<P>> createRanks() => _ranks!;

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
        _GroupPhasePlacement(ranking: group.finalRanking, place: place),
      ),
    );
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
/// The [_GroupPhasePlacement] prevents this player from going to the next
/// round, instead giving the would be opponent of the 2nd place a bye round.
class _GroupPhasePlacement<P> extends Placement<P> {
  _GroupPhasePlacement({
    required TieableMatchRanking<P, dynamic, TournamentMatch<P, dynamic>>
        ranking,
    required super.place,
  }) : super(ranking: ranking);

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
