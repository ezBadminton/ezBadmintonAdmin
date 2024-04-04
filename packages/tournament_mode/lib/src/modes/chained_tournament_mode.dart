import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/rankings/ranking_decorator.dart';
import 'package:tournament_mode/src/tournament_match.dart';
import 'package:tournament_mode/src/tournament_mode.dart';
import 'package:tournament_mode/src/tournament_round.dart';

/// Builds a [TournamentMode] from a [Ranking] containing the entries.
typedef TournamentModeBuilder<P, S, M extends TournamentMatch<P, S>,
        T extends TournamentMode<P, S, M>>
    = T Function(Ranking<P> entries);

typedef RankingTransition<P> = RankingDecorator<P> Function(
  Ranking<P> finalRanking,
);

/// A chain of two tournament modes where the final ranking of the first
/// gets forwarded into the entry list of the second tournament mode.
class ChainedTournamentMode<
    P,
    S,
    M extends TournamentMatch<P, S>,
    T1 extends TournamentMode<P, S, M>,
    T2 extends TournamentMode<P, S, M>> extends TournamentMode<P, S, M> {
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
    required TournamentModeBuilder<P, S, M, T1> firstBuilder,
    required TournamentModeBuilder<P, S, M, T2> secondBuilder,
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

  late final T1 first;
  late final T2 second;

  @override
  Ranking<P> get finalRanking => second.finalRanking;

  @override
  List<M> get matches => rounds.expand((round) => round.matches).toList();

  @override
  List<TournamentRound<M>> get rounds => [
        ...first.rounds,
        ...second.rounds,
      ];

  @override
  List<M> getEditableMatches() {
    return [
      ...first.getEditableMatches(),
      ...second.getEditableMatches(),
    ];
  }

  @override
  List<M> withdrawPlayer(P player) {
    return [
      ...first.withdrawPlayer(player),
      ...second.withdrawPlayer(player),
    ];
  }

  @override
  List<M> reenterPlayer(P player) {
    return [
      ...first.reenterPlayer(player),
      ...second.reenterPlayer(player),
    ];
  }
}
