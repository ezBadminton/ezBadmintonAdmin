import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/rankings/tieable_ranking.dart';
import 'package:tournament_mode/src/tournament_match.dart';
import 'package:collection/collection.dart';

/// A ranking based on match results.
abstract class MatchRanking<P, S, M extends TournamentMatch<P, S>>
    implements Ranking<P> {
  List<List<M>>? _rounds;
  List<List<M>>? get rounds => _rounds;
  Iterable<M>? get matches => _rounds?.expand((round) => round);

  void initRounds(List<List<M>> rounds) {
    _rounds = rounds;
  }

  bool ranksAvailable() {
    if (_rounds == null) {
      return false;
    }

    bool ranksAvailable = matches!
            .where((match) => !match.isBye)
            .firstWhereOrNull((match) => !match.hasWinner) ==
        null;

    return ranksAvailable;
  }
}

abstract class TieableMatchRanking<P, S, M extends TournamentMatch<P, S>>
    extends MatchRanking<P, S, M> with TieableRanking<P> {
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
