import 'package:collection/collection.dart';
import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/ranking.dart';

/// A [Ranking] that possibly has multiple participants on a single rank (ties).
mixin TieableRanking<P> implements Ranking<P> {
  @override
  List<MatchParticipant<P>> get ranks => tiedRanks.flattened.toList();

  List<List<MatchParticipant<P>>>? _frozenTiedRanks;

  List<List<MatchParticipant<P>>> get tiedRanks =>
      _frozenTiedRanks ?? createTieBrokenRanks();

  @override
  void freezeRanks() {
    _frozenTiedRanks = createTieBrokenRanks();
  }

  /// Returns a list of lists of [MatchParticipant]s ordered by rank.
  ///
  /// A list with multiple [MatchParticipant]s in it means they are tied and
  /// occupy the same rank.
  List<List<MatchParticipant<P>>> createTiedRanks();

  @override
  List<MatchParticipant<P>> createRanks() {
    return createTieBrokenRanks().flattened.toList();
  }

  /// Returns the ranks from [createTiedRanks] but with the [tieBreakers]
  /// applied.
  ///
  /// This does not guarantee no ties as the [tieBreakers] could be empty
  /// or do not contain breakers for all ties.
  List<List<MatchParticipant<P>>> createTieBrokenRanks() {
    return createTiedRanks().expand((tie) => _tryTieBreak(tie)).toList();
  }

  /// Add [Ranking]s to this list that rank the participants who are tied.
  /// The [createTieBrokenRanks] method will use them to break the ties.
  ///
  /// For example this could contain the result of a coin toss or a
  /// tie-breaker match.
  List<Ranking<P>> tieBreakers = [];

  /// Set this to check that the output from [createRanks] has no ties in the
  /// first [requiredUntiedRanks].
  ///
  /// The ties that are blocking this requirement can be read from
  /// the [blockingTies] property.
  ///
  /// This does not guarantee that this many ranks exist. If less ranks exist
  /// that have no ties they will be returned by [createRanks].
  int requiredUntiedRanks = 0;

  /// Returns the ties that need to be broken in order to fulfill
  /// [requiredUntiedRanks].
  List<List<MatchParticipant<P>>> get blockingTies => createTieBrokenRanks()
      .whereIndexed(
          (index, tie) => tie.length > 1 && index < requiredUntiedRanks)
      .toList();

  /// Try to find one of the [tieBreakers] that can break the given [tie].
  List<List<MatchParticipant<P>>> _tryTieBreak(
    List<MatchParticipant<P>> tie,
  ) {
    if (tie.length == 1) {
      return [tie];
    }

    for (Ranking<P> tieBreaker in tieBreakers) {
      List<P> tieBreakerRanks = tieBreaker
          .createRanks()
          .where((participant) => participant.resolvePlayer() != null)
          .map((participant) => participant.resolvePlayer()!)
          .toList();
      List<P> tiedPlayers =
          tie.map((participant) => participant.resolvePlayer()!).toList();

      bool canBreakTie =
          !tiedPlayers.map((p) => tieBreakerRanks.contains(p)).contains(false);

      if (canBreakTie) {
        List<MatchParticipant<P>> ranks = tie
            .sortedBy<num>((participant) => tieBreakerRanks
                .indexWhere((player) => player == participant.resolvePlayer()))
            .toList();

        return ranks.map((participant) => [participant]).toList();
      }
    }

    // No fitting tie breaker found
    return [tie];
  }

  /// Returns a list of all current unbroken ties
  List<List<MatchParticipant<P>>> get ties =>
      createTieBrokenRanks().where((tie) => tie.length > 1).toList();

  /// Is true while at least one rank is occupied by more than one participant
  /// because they are tied and none of the [tieBreakers] apply.
  bool get hasTies =>
      createTieBrokenRanks().firstWhereOrNull((tie) => tie.length > 1) != null;

  /// See [hasTies]
  bool get hasNoTies => !hasTies;

  /// Returns the rank indices of the [ranks].
  ///
  /// The returned list has the same length as [ranks]. The rank indices
  /// respect tied ranks.
  ///
  /// The first rank always has index 0.
  ///
  /// Example: When two players are tied in the first rank, then the index of
  /// the second rank is 2, because the first rank "spans" the indices 0 and 1.
  static List<int> getRankIndices(List<List<Object>> ranks) {
    int index = 0;
    List<int> rankIndices = [];

    for (List<Object> rank in ranks) {
      rankIndices.add(index);

      index += rank.length;
    }

    return rankIndices;
  }
}
