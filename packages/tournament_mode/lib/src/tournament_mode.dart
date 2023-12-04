import 'package:collection/collection.dart';
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

  /// Returns the earliest round that still has unfinished matches
  ///
  /// Returns `-1` if all matches are completed.
  int ongoingRound() {
    for (int i = 0; i < rounds.length; i += 1) {
      bool ongoing = roundMatches
              .elementAt(i)
              .where((match) => !match.isBye)
              .firstWhereOrNull((match) => !match.isCompleted) !=
          null;
      if (ongoing) {
        return i;
      }
    }

    return -1;
  }

  /// Returns the latest round that already has one or more matches in progress
  /// or completed.
  ///
  /// Returns `0` if no matches have been started.
  int latestOngoingRound() {
    for (int i = rounds.length - 1; i >= 0; i -= 1) {
      bool inProgress = roundMatches
              .elementAt(i)
              .where((match) => !match.isBye)
              .firstWhereOrNull((match) => match.startTime != null) !=
          null;
      if (inProgress) {
        return i;
      }
    }

    return 0;
  }

  /// Returns how many rounds are currently in progress at once.
  ///
  /// This is useful for scheduling (e.g. a group phase) to not make the
  /// progress between the rounds too unbalanced.
  int roundLag() {
    if (isCompleted()) {
      return 0;
    }
    return latestOngoingRound() - ongoingRound() + 1;
  }

  /// Returns whether all [matches] are completed.
  bool isCompleted() {
    return matches
            .where((match) => !match.isBye)
            .firstWhereOrNull((match) => !match.isCompleted) ==
        null;
  }
}
