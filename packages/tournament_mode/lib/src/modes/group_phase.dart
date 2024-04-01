import 'package:collection/collection.dart';
import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/modes/round_robin.dart';
import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/rankings/draw_seeds.dart';
import 'package:tournament_mode/src/rankings/group_phase_ranking.dart';
import 'package:tournament_mode/src/rankings/match_ranking.dart';
import 'package:tournament_mode/src/round_types/group_phase_round.dart';
import 'package:tournament_mode/src/tournament_match.dart';
import 'package:tournament_mode/src/tournament_mode.dart';

/// A group phase where each group plays through one round robin.
class GroupPhase<P, S, M extends TournamentMatch<P, S>,
    R extends RoundRobin<P, S, M>> extends TournamentMode<P, S, M> {
  /// Creates a [GroupPhase] with [numGroups]
  GroupPhase({
    required this.entries,
    required this.numGroups,
    required this.numQualifications,
    required this.roundRobinBuilder,
    required this.crossGroupRanking,
  }) {
    _createMatches();
    crossGroupRanking.initRounds(roundMatches.toList());
    _finalRanking = GroupPhaseRanking(this);
  }

  /// The players are entered in a seeded Ranking (e.g. [DrawSeeds])
  ///
  /// If no seeding is needed a random ranking can be used aswell.
  @override
  final Ranking<P> entries;

  /// The number of groups to split the players into.
  ///
  /// If the number of players is not divisible by [numGroups], the first
  /// group(s) will have one less member.
  final int numGroups;

  /// The number of players who will qualify for the next round after the
  /// group phase.
  final int numQualifications;

  /// A function turning a ranking of entries into a specific [RoundRobin].
  final R Function(Ranking<P> entries) roundRobinBuilder;

  /// A [TieableMatchRanking] that will be used to rank all players by their
  /// stats across all groups.
  final TieableMatchRanking<P, S, M> crossGroupRanking;

  /// Each group is a realized as a [RoundRobin] ([R]) tournament.
  late final List<R> groupRoundRobins;

  @override
  List<M> get matches =>
      [for (GroupPhaseRound<M> round in rounds) ...round.matches];

  late List<GroupPhaseRound<M>> _rounds;
  @override
  List<GroupPhaseRound<M>> get rounds => _rounds;

  late final GroupPhaseRanking<P, S, M> _finalRanking;
  @override
  GroupPhaseRanking<P, S, M> get finalRanking => _finalRanking;

  void _createMatches() {
    List<MatchParticipant<P>> participants = entries.ranks;

    List<List<MatchParticipant<P>>> groups =
        _createSeededGroups(participants, numGroups);

    groupRoundRobins = groups
        .map(
          (group) => roundRobinBuilder(DrawSeeds.fromParticipants(group)),
        )
        .toList();

    _rounds = _getGroupPhaseRounds();
  }

  /// Distributes the [participants] into [numGroups] groups.
  ///
  /// The group members are assigned to the groups in a "snake" order:
  /// * One member is assigned to each group starting with the first group and
  /// first entry in the [participants].
  /// * The second member is assigned starting with the last group,
  /// going back towards the first.
  /// * The back and forth continues until the members are equally distributed.
  /// * When the number of participants is not divisible by [numGroups], the
  /// remaining participants are assigned last group first, leaving the
  /// first groups with fewer members.
  List<List<MatchParticipant<P>>> _createSeededGroups(
    List<MatchParticipant<P>> participants,
    int numGroups,
  ) {
    int minGroupSize = participants.length ~/ numGroups;

    List<List<MatchParticipant<P>>> groups =
        List.generate(numGroups, (_) => []);

    for (int i = 0; i < minGroupSize; i += 1) {
      // Group neighbours are participants who occupy the same index in the list
      // of each group (one row in the group table)
      List<MatchParticipant<P>> groupNeighbours =
          participants.sublist(i * numGroups, (i + 1) * numGroups);
      if (!i.isEven) {
        groupNeighbours = groupNeighbours.reversed.toList();
      }

      for (int g = 0; g < numGroups; g += 1) {
        groups[g].add(groupNeighbours[g]);
      }
    }

    List<MatchParticipant<P>> remaining =
        participants.sublist(minGroupSize * numGroups);

    if (minGroupSize.isEven) {
      // keep the snaking direction after skipping the first group(s)
      remaining = remaining.reversed.toList();
    }

    for (int i = 0; i < remaining.length; i += 1) {
      groups[numGroups - 1 - i].add(remaining[i]);
    }

    return groups;
  }

  List<GroupPhaseRound<M>> _getGroupPhaseRounds() {
    int maxRounds =
        groupRoundRobins.map((roundRobin) => roundRobin.rounds.length).max;

    List<GroupPhaseRound<M>> rounds = List.generate(
      maxRounds,
      (round) => GroupPhaseRound(
        groupRoundRobins: groupRoundRobins,
        tournament: this,
        roundNumber: round,
        totalRounds: maxRounds,
      )..initMatches(),
    );

    return rounds;
  }

  @override
  List<M> getEditableMatches() {
    return groupRoundRobins.expand((r) => r.getEditableMatches()).toList();
  }

  @override
  List<M> withdrawPlayer(P player, [bool forceWalkover = false]) {
    return groupRoundRobins
        .expand((r) => r.withdrawPlayer(player, forceWalkover))
        .toList();
  }

  @override
  List<M> reenterPlayer(P player) {
    return groupRoundRobins.expand((r) => r.reenterPlayer(player)).toList();
  }

  int getGroupOfPlayer(P player) {
    return groupRoundRobins.indexWhere(
      (r) => r.participants.map((p) => p.resolvePlayer()).contains(player),
    );
  }
}
