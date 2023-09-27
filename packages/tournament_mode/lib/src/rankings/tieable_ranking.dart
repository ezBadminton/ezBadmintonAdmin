import 'package:collection/collection.dart';
import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/ranking.dart';

/// A [Ranking] that possibly has multiple participants on a single rank (ties).
mixin TieableRanking<P> implements Ranking<P> {
  /// Returns a list of lists of [MatchParticipant]s ordered by rank.
  ///
  /// A list with multiple [MatchParticipant]s in it means they are tied and
  /// occupy the same rank.
  List<List<MatchParticipant<P>>> tiedRank();

  @override
  List<MatchParticipant<P>> rank() {
    return tieBreakingRank().expand((tie) => tie).toList();
  }

  /// Returns the [tiedRank] but with the [tieBreakers] applied.
  ///
  /// This does not guarantee no ties as the [tieBreakers] could be empty
  /// or do not contain breakers for all ties.
  List<List<MatchParticipant<P>>> tieBreakingRank() {
    return tiedRank().expand((tie) => _tryTieBreak(tie)).toList();
  }

  /// Add [Ranking]s to this list that rank the participants who are tied.
  /// The [tieBreakingRank] method will use them to break the ties.
  ///
  /// For example this could contain the result of a coin toss or a
  /// tie-breaker match.
  List<Ranking<P>> tieBreakers = [];

  /// Try to find one of the [tieBreakers] that can break the given [tie].
  List<List<MatchParticipant<P>>> _tryTieBreak(
    List<MatchParticipant<P>> tie,
  ) {
    if (tie.length == 1) {
      return [tie];
    }

    for (Ranking<P> tieBreaker in tieBreakers) {
      List<P> tieBreakerRanks = tieBreaker
          .rank()
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
            .reversed
            .toList();

        return ranks.map((participant) => [participant]).toList();
      }
    }

    // No fitting tie breaker found
    return [tie];
  }

  /// Returns a list of all current unbroken ties
  List<List<MatchParticipant<P>>> get ties =>
      tieBreakingRank().where((tie) => tie.length > 1).toList();

  /// Is true while at least one rank is occupied by more than one participant
  /// because they are tied and none of the [tieBreakers] apply.
  bool get hasTies =>
      tieBreakingRank().firstWhereOrNull((tie) => tie.length > 1) != null;

  /// See [hasTies]
  bool get hasNoTies => !hasTies;
}
