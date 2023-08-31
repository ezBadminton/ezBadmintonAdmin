import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/rankings/ranking_decorator.dart';
import 'package:tournament_mode/src/tournament_match.dart';
import 'package:tournament_mode/src/tournament_mode.dart';
import 'package:tournament_mode/src/tournament_round.dart';

/// Builds a [TournamentMode] from a [Ranking] containing the entries.
typedef TournamentModeBuilder<P, S> = TournamentMode<P, S> Function(
  Ranking<P> entries,
);

typedef RankingTransition<P> = RankingDecorator<P> Function(
  Ranking<P> finalRanking,
);

/// A chain of two tournament modes where the final ranking of the first
/// gets forwarded into the entry list of the second tournament mode.
class ChainedTournamentMode<P, S> extends TournamentMode<P, S> {
  /// Chains the tournament mode of [firstBuilder] to that
  /// of [secondBuilder].
  ///
  /// The [entries] are directly used to build the first tournament mode.
  /// The second tournament mode is built with the [TournamentMode.finalRanking]
  /// of the first tournament mode.
  ///
  /// If [rankingTransition] is not `null` then the entry ranking of the second
  /// mode (which is the final ranking of the first) is transitioned first.
  ChainedTournamentMode({
    required this.entries,
    required TournamentModeBuilder<P, S> firstBuilder,
    required TournamentModeBuilder<P, S> secondBuilder,
    RankingTransition<P>? rankingTransition,
  }) {
    first = firstBuilder(entries);
    if (rankingTransition == null) {
      second = secondBuilder(first.finalRanking);
    } else {
      second = secondBuilder(rankingTransition(first.finalRanking));
    }
  }

  @override
  final Ranking<P> entries;

  late final TournamentMode<P, S> first;
  late final TournamentMode<P, S> second;

  @override
  Ranking<P> get finalRanking => second.finalRanking;

  @override
  List<TournamentMatch<P, S>> get matches =>
      rounds.expand((round) => round).toList();

  @override
  List<TournamentRound<P, S>> get rounds => [
        ...first.rounds,
        ...second.rounds,
      ];
}
