import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/tournament_match.dart';
import 'package:collection/collection.dart';

/// A ranking based on match results.
abstract class MatchRanking<P, S> implements Ranking<P> {
  List<List<TournamentMatch<P, S>>>? _rounds;
  List<List<TournamentMatch<P, S>>>? get rounds => _rounds;
  Iterable<TournamentMatch<P, S>>? get matches =>
      _rounds?.expand((round) => round);

  void initRounds(List<List<TournamentMatch<P, S>>> rounds) {
    _rounds = rounds;
  }

  bool ranksAvailable() {
    if (_rounds == null) {
      return false;
    }

    return matches!
            .where((match) => !match.isBye())
            .firstWhereOrNull((match) => !match.isCompleted) ==
        null;
  }
}
