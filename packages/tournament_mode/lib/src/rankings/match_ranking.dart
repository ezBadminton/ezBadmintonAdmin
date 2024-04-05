import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/rankings/match_dependant_ranking.dart';
import 'package:tournament_mode/src/rankings/tieable_ranking.dart';
import 'package:tournament_mode/src/tournament_match.dart';
import 'package:collection/collection.dart';

/// A ranking based on match results.
abstract class MatchRanking<P, S, M extends TournamentMatch<P, S>>
    extends Ranking<P> with MatchDependantRanking<P, M> {
  List<List<M>>? _rounds;
  List<List<M>>? get rounds => _rounds;
  Iterable<M>? get matches => _rounds?.expand((round) => round);

  void initRounds(List<List<M>> rounds) {
    _rounds = rounds;
  }

  @override
  List<M> get matchDependencies => matches?.toList() ?? [];

  bool allMatchesComplete() {
    if (_rounds == null) {
      return false;
    }

    bool matchesComplete =
        matches!.firstWhereOrNull((match) => !match.hasWinner) == null;

    return matchesComplete;
  }
}

abstract class TieableMatchRanking<P, S, M extends TournamentMatch<P, S>>
    extends MatchRanking<P, S, M> with TieableRanking<P> {}
