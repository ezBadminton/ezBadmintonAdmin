import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/tournament_match.dart';

/// A mixin for all [Ranking]s where the ranks are directly dependant on match
/// results.
mixin MatchDependantRanking<P, M extends TournamentMatch> on Ranking<P> {
  /// The list of all matches that influence this ranking.
  List<M> get matchDependencies;

  /// Returns whether any of the [matchDependencies] are dirty, e.g. their
  /// result changed since the last update.
  bool didMatchesChange() {
    for (TournamentMatch m in matchDependencies) {
      if (m.isDirty) {
        return true;
      }
    }

    return false;
  }
}
