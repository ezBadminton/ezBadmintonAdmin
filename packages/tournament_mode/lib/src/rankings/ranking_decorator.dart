import 'package:tournament_mode/src/ranking.dart';

/// A decorator for [Ranking]s.
///
/// This ranking ranks the players according to the [targetRanking] with some
/// modification made to the list. E.g. remove the ranks that are disqualified.
abstract class RankingDecorator<P> implements Ranking<P> {
  /// Creates a [RankingDecorator] for the [targetRanking]
  RankingDecorator(this.targetRanking);

  final Ranking<P> targetRanking;
}
