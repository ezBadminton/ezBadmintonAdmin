import 'package:collection/collection.dart';
import 'package:tournament_mode/src/modes/group_phase.dart';
import 'package:tournament_mode/src/modes/single_elimination.dart';
import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/rankings/match_dependant_ranking.dart';
import 'package:tournament_mode/src/tournament_match.dart';
import 'package:tournament_mode/src/tournament_round.dart';

import 'package:graphs/graphs.dart' as graphs;

/// A tournament mode made up of specifically chained stages of matches.
///
/// It is basically a process to determine how the [entries]
/// transform into the [finalRanking].
///
/// The [finalRanking] can then be used as the [entries] for another mode,
/// effectively chaining them (e.g. [GroupPhase] => [SingleElimination]).
abstract class TournamentMode<P, S, M extends TournamentMatch<P, S>> {
  /// The participants of this tournament mode in a ranked entry list.
  ///
  /// The [entries] ranking can be interpreted as a seeded list, as the result
  /// from a tournament mode that came before this in the chain or just as
  /// a list with no meaning in the order.
  abstract final Ranking<P> entries;

  /// All matches that are played in this mode.
  List<M> get matches;

  /// The [matches] grouped into rounds.
  /// Every match is part of exactly one round.
  ///
  /// A round is a set of matches that can be played in parallel
  /// given the previous round has completed. The list's order reflects the
  /// order of the rounds.
  List<TournamentRound<M>> get rounds;

  Iterable<List<M>> get roundMatches => rounds.map((r) => r.matches);

  /// The final ranks of the players after all matches are finished.
  Ranking<P> get finalRanking;

  /// Returns the list of matches ([M]) where the score can be edited.
  ///
  /// This is not always possible for all matches since some tournament modes
  /// have temporal dependencies between rounds.
  /// E.g. a single elimination match can't be changed once the next round
  /// started.
  List<M> getEditableMatches();

  /// Called when a [player] withdraws from the tournament.
  ///
  /// Returns a list of matches that become walkovers because the [player]
  /// withdrew.
  List<M> withdrawPlayer(P player);

  /// Called when a [player] who previously withdrew from the tournament
  /// reenters.
  ///
  /// This is not always possible for all matches since some tournament modes
  /// have temporal dependencies between rounds.
  /// E.g. a single elimination match can't be changed once the next round
  /// started.
  ///
  /// Returns a list of matches that can be reverted from their walkover status
  /// while keeping the tournament progression intact.
  List<M> reenterPlayer(P player);

  /// Returns whether all [matches] are completed.
  bool isCompleted() {
    return matches.firstWhereOrNull((match) => !match.hasWinner) == null;
  }

  Iterable<M> getMatchesOfPlayer(P player) {
    return matches
        .where(
          (m) => !m.isDrawnBye,
        )
        .where(
          (m) => m.a.player == player || m.b.player == player,
        );
  }

  void updateTournament({bool forceCompleteUpdate = false}) {
    for (M match in matches) {
      match.updateFingerprint();
    }

    List<Ranking<P>> rankings =
        forceCompleteUpdate ? crawlRankings() : crawlUpdatableRankings();

    for (Ranking<P> ranking in rankings) {
      ranking.update();
    }

    for (M match in matches) {
      match.setClean();
    }
  }

  /// Returns all rankings in this tournament.
  ///
  /// They are topologically sorted such that each ranking comes before
  /// every ranking that depends on it.
  ///
  /// This is the order that the rankings have to be updated in so that no
  /// ranking updates with the data of a not-yet-updated dependency.
  List<Ranking<P>> crawlRankings([Ranking<P>? root]) {
    Set<Ranking<P>> rankings = {};

    Set<Ranking<P>> currentRankings = {root ?? entries};
    while (currentRankings.isNotEmpty) {
      rankings.addAll(currentRankings);

      Set<Ranking<P>> crawlingNodes = Set.from(currentRankings);
      currentRankings.clear();

      for (Ranking<P> ranking in crawlingNodes) {
        currentRankings.addAll(ranking.dependantRankings);
      }
    }

    return graphs.topologicalSort(rankings, (r) => r.dependantRankings);
  }

  /// Returns the rankings that have to update because one of the matches or
  /// another ranking that they depend on changed.
  ///
  /// This prevents for example the group phase rankings to update every time
  /// a match in the Knock-Out phase is updated.
  List<Ranking<P>> crawlUpdatableRankings() {
    List<Ranking<P>> rankings = crawlRankings();

    Ranking<P>? firstUpdatable = rankings.firstWhereOrNull((r) =>
        r is MatchDependantRanking &&
        (r as MatchDependantRanking).didMatchesChange());

    if (firstUpdatable == null) {
      return [];
    }

    List<Ranking<P>> updatableRankings = crawlRankings(firstUpdatable);

    return updatableRankings;
  }
}
