import 'package:collection/collection.dart';
import 'package:tournament_mode/src/tournament_match.dart';
import 'package:tournament_mode/src/tournament_mode.dart';

/// Interface of tournament modes that have a direct qualification chain
/// between matches.
///
/// This is most commonly the case in elimination modes.
///
/// The implementing modes should populate the [TournamentMatch.nextMatches]
/// list of their matches and use it to implement the methods of this
/// interface.
abstract class QualificationChain<M extends TournamentMatch> {
  /// Returns the next match(es) in the qualification chain
  /// of the given [match].
  ///
  /// When the returned List contains 2 matches, the first one is the match
  /// that the winner qualifies for and the second is the one that the loser
  /// qualifies for.
  /// If it is only one match then the loser of the [match] is out.
  /// When the returned list is empty, the given [match] was a final.
  List<M> getNextMatches(M match);

  /// Returns the next matches in the qualification chain of the given [match]
  /// that are not a bye or a walkover.
  ///
  /// The next matches in the qualification chain are obtained by calling the
  /// [getNextMatches] function.
  List<M> getNextPlayableMatches(M match);
}

mixin EliminationChain<P, S, M extends TournamentMatch<P, S>>
    on TournamentMode<P, S, M> implements QualificationChain<M> {
  @override
  List<M> getNextMatches(M match) => match.nextMatches.cast<M>();

  @override
  List<M> getNextPlayableMatches(
    M match,
  ) {
    Set<M> nextMatches = getNextMatches(match).toSet();

    Set<M> unplayableMatches =
        nextMatches.where((m) => m.isBye || m.isWalkover).toSet();

    Set<M> nextMatchesOfUnplayableMatches =
        unplayableMatches.expand((m) => getNextPlayableMatches(m)).toSet();

    nextMatches.removeAll(unplayableMatches);
    nextMatches.addAll(nextMatchesOfUnplayableMatches);

    return nextMatches.toList();
  }

  @override
  List<M> getEditableMatches() {
    List<M> editableMatches = matches
        .where((match) => match.hasWinner && !match.isWalkover && !match.isBye)
        .where((match) {
      List<M> nextMatches = getNextPlayableMatches(match);

      bool doNextMatchesAllowEditing = nextMatches.fold(
        true,
        (allowEditing, match) => allowEditing && !match.hasWinner,
      );

      return doNextMatchesAllowEditing;
    }).toList();

    return editableMatches;
  }

  @override
  List<M> withdrawPlayer(P player) {
    M? walkoverMatch = getMatchesOfPlayer(player).firstWhereOrNull(
      (m) {
        if (!m.hasWinner) {
          return true;
        }

        if (m.isDrawnBye || !(m.isBye || m.isWalkover)) {
          return false;
        }

        // A player can withdraw from a match that is already a walkover
        // when the next matches of the walkover have not started yet.

        List<M> nextMatches = getNextPlayableMatches(m);

        bool haveNextMatchesStarted = nextMatches.fold(
          false,
          (haveStarted, match) => haveStarted || match.startTime != null,
        );

        bool walkoverNotInEffect =
            nextMatches.isNotEmpty && !haveNextMatchesStarted;

        return walkoverNotInEffect;
      },
    );

    if (walkoverMatch == null) {
      return [];
    }

    return [walkoverMatch];
  }

  @override
  List<M> reenterPlayer(P player) {
    List<M> withdrawnMatchesOfPlayer = matches
        .where((m) => m.isWalkover)
        .where(
          (m) => m.withdrawnParticipants!
              .map((p) => p.resolvePlayer())
              .contains(player),
        )
        .toList();

    List<M> reenteringMatches = withdrawnMatchesOfPlayer.where(
      (match) {
        List<M> nextMatches = getNextPlayableMatches(match);

        bool haveNextMatchesStarted = nextMatches.fold(
          false,
          (haveStarted, match) => haveStarted || match.startTime != null,
        );

        return !haveNextMatchesStarted;
      },
    ).toList();

    return reenteringMatches;
  }
}
