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

    return matches!
            .where((match) => !match.isBye)
            .firstWhereOrNull((match) => !match.isCompleted) ==
        null;
  }
}

abstract class TieableMatchRanking<P, S, M extends TournamentMatch<P, S>>
    extends MatchRanking<P, S, M> with TieableRanking<P> {}
