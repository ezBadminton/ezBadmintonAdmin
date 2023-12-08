import 'package:collection/collection.dart';
import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/modes/group_phase.dart';
import 'package:tournament_mode/src/modes/single_elimination.dart';
import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/tournament_match.dart';
import 'package:tournament_mode/src/tournament_round.dart';

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
          (m) => m.a.resolvePlayer() == player || m.b.resolvePlayer() == player,
        );
  }

  /// Freeze all rankings of this tournament.
  ///
  /// Particularly this includes the [entries], the [finalRanking] and all
  /// rankings that are used in a [MatchParticipant.fromPlacement].
  ///
  /// This should be done after the tournament's match results have been loaded
  /// into the matches from storage.
  ///
  /// Without frozen rankings every call to [MatchParticipant.resolvePlayer]
  /// triggers a full recalculation of the ranking chain that leads to
  /// the qualification of the participant. This can become very expensive when
  /// the tournament mode is being displayed and every participant potentially
  /// needs to be resolved multiple times.
  void freezeRankings() {
    Set<Ranking> rankings = matches
        .expand(
            (match) => [match.a.placement?.ranking, match.b.placement?.ranking])
        .whereType<Ranking>()
        .toSet();

    rankings.add(entries);
    rankings.add(finalRanking);

    for (Ranking ranking in rankings) {
      ranking.freezeRanks();
    }
  }
}
