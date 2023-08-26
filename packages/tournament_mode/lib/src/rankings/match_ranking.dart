import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/tournament_match.dart';
import 'package:collection/collection.dart';

/// A ranking based on match results.
abstract class MatchRanking<P, S> implements Ranking<P> {
  List<TournamentMatch<P, S>>? _matches;
  List<TournamentMatch<P, S>>? get matches => _matches;

  void initMatches(List<TournamentMatch<P, S>> matches) {
    _matches = matches;
  }

  bool ranksAvailable() {
    if (_matches == null) {
      return false;
    }

    return _matches!
            .where((match) => !match.isBye())
            .firstWhereOrNull((match) => !match.isCompleted) ==
        null;
  }
}
