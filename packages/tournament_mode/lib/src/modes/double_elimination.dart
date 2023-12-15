import 'package:collection/collection.dart';
import 'package:dart_numerics/dart_numerics.dart';
import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/modes/single_elimination.dart';
import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/rankings/double_elimination_ranking.dart';
import 'package:tournament_mode/src/rankings/winner_ranking.dart';
import 'package:tournament_mode/src/round_types/double_elimination_round.dart';
import 'package:tournament_mode/src/round_types/elimination_round.dart';
import 'package:tournament_mode/src/tournament_match.dart';
import 'package:tournament_mode/src/tournament_mode.dart';

class DoubleElimination<P, S, M extends TournamentMatch<P, S>,
    E extends SingleElimination<P, S, M>> extends TournamentMode<P, S, M> {
  DoubleElimination({
    required Ranking<P> seededEntries,
    required this.singleEliminationBuilder,
  }) : winnerBracket = singleEliminationBuilder(seededEntries) {
    _createMatches();
    finalRanking = DoubleEliminationRanking(doubleEliminationTournament: this);
  }

  final E Function(Ranking<P> entries) singleEliminationBuilder;

  M Function(
    MatchParticipant<P> a,
    MatchParticipant<P> b,
  ) get matcher => winnerBracket.matcher;

  final E winnerBracket;

  @override
  Ranking<P> get entries => winnerBracket.entries;

  @override
  late final Ranking<P> finalRanking;

  late List<DoubleEliminationRound<M>> _rounds;
  @override
  List<DoubleEliminationRound<M>> get rounds => _rounds;

  @override
  List<M> get matches =>
      [for (DoubleEliminationRound<M> round in rounds) ...round.matches];

  void _createMatches() {
    List<DoubleEliminationRound<M>> rounds = [];

    DoubleEliminationRound<M> firstRound = DoubleEliminationRound(
      tournament: this,
      winnerRound: winnerBracket.rounds.first,
    );
    rounds.add(firstRound);

    List<M> firstIntakeMatches =
        _createFirstIntakeMatches(winnerBracket.rounds[1].matches);

    EliminationRound<M> firstIntakeRound = EliminationRound(
      matches: firstIntakeMatches,
      tournament: this,
      roundSize: firstIntakeMatches.length * 2,
      roundDepth: 1,
    );

    DoubleEliminationRound<M> secondRound = DoubleEliminationRound(
      tournament: this,
      winnerRound: winnerBracket.rounds[1],
      loserRound: firstIntakeRound,
    );
    rounds.add(secondRound);

    List<M> previousEliminationMatches = firstIntakeMatches;
    for (int i = 1; i < winnerBracket.rounds.length - 1; i += 1) {
      EliminationRound<M> winnerRound = winnerBracket.rounds[i];

      List<M> intakeMatches = _createIntakeMatches(
        previousEliminationMatches,
        winnerRound.matches,
      );

      EliminationRound<M> intakeRound = EliminationRound(
        matches: intakeMatches,
        tournament: this,
        roundSize: intakeMatches.length * 2,
        roundDepth: 1,
      );
      DoubleEliminationRound<M> doubleEliminationIntakeRound =
          DoubleEliminationRound(
        tournament: this,
        loserRound: intakeRound,
      );
      rounds.add(doubleEliminationIntakeRound);

      winnerRound = winnerBracket.rounds[i + 1];
      List<M> eliminationMatches = _createEliminationMatches(intakeMatches);

      EliminationRound<M> loserEliminationRound = EliminationRound(
        matches: eliminationMatches,
        tournament: this,
        roundSize: eliminationMatches.length * 2,
        roundDepth: 1,
      );
      DoubleEliminationRound<M> doubleEliminationRound = DoubleEliminationRound(
        tournament: this,
        winnerRound: winnerRound,
        loserRound: loserEliminationRound,
      );
      rounds.add(doubleEliminationRound);

      previousEliminationMatches = eliminationMatches;
    }

    List<M> loserFinalMatch = _createIntakeMatches(
      previousEliminationMatches,
      winnerBracket.rounds.last.matches,
    );
    EliminationRound<M> loserFinalRound = EliminationRound(
      matches: loserFinalMatch,
      tournament: this,
      roundSize: 2,
      roundDepth: 1,
    );
    DoubleEliminationRound<M> doubleEliminationLoserFinalRound =
        DoubleEliminationRound(
      tournament: this,
      loserRound: loserFinalRound,
    );
    rounds.add(doubleEliminationLoserFinalRound);

    M finalMatch = _createFinal(loserFinalMatch.single);
    EliminationRound<M> finalRound = EliminationRound(
      matches: [finalMatch],
      tournament: this,
      roundSize: 2,
    );
    DoubleEliminationRound<M> doubleEliminationFinalRound =
        DoubleEliminationRound(
      tournament: this,
      winnerRound: finalRound,
    );
    rounds.add(doubleEliminationFinalRound);

    _rounds = rounds;
  }

  /// The first intake round matches all the losers from the first
  /// winner bracket round.
  List<M> _createFirstIntakeMatches(List<M> secondWinnerRound) {
    List<M> firstLoserRound = secondWinnerRound.map((match) {
      MatchParticipant<P> loser1 = MatchParticipant.fromPlacement(
        Placement(ranking: match.a.placement!.ranking, place: 1),
      );
      MatchParticipant<P> loser2 = MatchParticipant.fromPlacement(
        Placement(ranking: match.b.placement!.ranking, place: 1),
      );

      return matcher(loser1, loser2);
    }).toList();

    return firstLoserRound;
  }

  /// The intake round matches the winners of the previous loser round with the
  /// losers who come down from the winner bracket.
  /// Also called the "minor loser round".
  List<M> _createIntakeMatches(
    List<M> previousEliminationRound,
    List<M> winnerRound,
  ) {
    assert(previousEliminationRound.length == winnerRound.length);

    // The first intake round has half as many participants as the first round
    // of the winner bracket (because it takes in all losers).
    int baseRoundSize = winnerBracket.rounds.first.roundSize ~/ 2;

    int intakeRoundIndex = log2(baseRoundSize ~/ (winnerRound.length * 2));

    Iterable<M> winnerRoundMatches;

    // On every even intake round, swap the first half of the winner round with
    // the second. This minimizes the chance of rematches from a winner round
    // in the loser bracket.
    if (intakeRoundIndex.isEven) {
      int halfLength = winnerRound.length ~/ 2;
      winnerRoundMatches =
          winnerRound.skip(halfLength).followedBy(winnerRound.take(halfLength));
    } else {
      winnerRoundMatches = winnerRound;
    }

    List<M> intakeRound = [];
    for (int i = 0; i < winnerRound.length; i += 1) {
      M eliminationMatch = previousEliminationRound[i];
      M winnerMatch = winnerRoundMatches.elementAt(i);

      WinnerRanking<P, S> eliminationMatchRanking =
          WinnerRanking(eliminationMatch);
      WinnerRanking<P, S> winnerMatchRanking = WinnerRanking(winnerMatch);

      MatchParticipant<P> eliminationMatchWinner =
          MatchParticipant.fromPlacement(
        Placement(ranking: eliminationMatchRanking, place: 0),
      );
      MatchParticipant<P> winnerMatchLoser = MatchParticipant.fromPlacement(
        Placement(ranking: winnerMatchRanking, place: 1),
      );

      M intakeMatch = matcher(winnerMatchLoser, eliminationMatchWinner);

      intakeRound.add(intakeMatch);
    }

    return intakeRound;
  }

  /// The elimination round halves the loser bracket like in
  /// a normal single elimination. Also called the "major loser round"
  List<M> _createEliminationMatches(List<M> intakeRound) {
    List<MatchParticipant<P>> intakeRoundWinners =
        winnerBracket.createNextRoundParticipants(intakeRound);

    List<M> eliminationRound =
        winnerBracket.createEliminationRound(intakeRoundWinners);

    return eliminationRound;
  }

  M _createFinal(M loserFinal) {
    WinnerRanking<P, S> winnerFinalRanking =
        WinnerRanking(winnerBracket.matches.last);
    WinnerRanking<P, S> loserFinalRanking = WinnerRanking(loserFinal);

    MatchParticipant<P> winnerFinalist = MatchParticipant.fromPlacement(
      Placement(ranking: winnerFinalRanking, place: 0),
    );
    MatchParticipant<P> loserFinalist = MatchParticipant.fromPlacement(
      Placement(ranking: loserFinalRanking, place: 0),
    );

    return matcher(winnerFinalist, loserFinalist);
  }

  @override
  List<M> getEditableMatches() {
    List<M> editableMatches = matches
        .where((match) => match.hasWinner && !match.isWalkover && !match.isBye)
        .where((match) {
      Set<M> nextMatches = getNextPlayableMatches([match]);

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

        Set<M> nextMatches = getNextPlayableMatches([m]);

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

    assert(withdrawnMatchesOfPlayer.length <= 1);

    if (withdrawnMatchesOfPlayer.isEmpty) {
      return [];
    }

    Set<M> nextMatches = getNextPlayableMatches(withdrawnMatchesOfPlayer);

    bool areNextMatchesInProgress = nextMatches.fold(
      false,
      (inProgress, match) => inProgress || match.startTime != null,
    );

    if (areNextMatchesInProgress) {
      return [];
    } else {
      return withdrawnMatchesOfPlayer;
    }
  }

  /// Returns the matches that the winner/loser of the [match] qualify for.
  ///
  /// When the returned List contains 2 matches, the first one is the match
  /// that the winner qualifies for and the second is the one that the loser
  /// qualifies for.
  /// If it is only one match then the loser of the [match] is out.
  /// When the returned list is empty, the given [match] was the final.
  List<M> getNextMatches(M match) {
    DoubleEliminationRound<M> roundOfMatch =
        rounds.firstWhere((r) => r.matches.contains(match));

    M? nextWinnerBracketMatch = _getNextWinnerBracketMatch(match, roundOfMatch);
    M? nextLoserBracketMatch = _getNextLoserBracketMatch(match, roundOfMatch);

    return [
      if (nextWinnerBracketMatch != null) nextWinnerBracketMatch,
      if (nextLoserBracketMatch != null) nextLoserBracketMatch,
    ];
  }

  /// Returns the matches in the qualification chain of the given [matches] that
  /// are not a bye or a walkover.
  Set<M> getNextPlayableMatches(Iterable<M> matches) {
    if (matches.isEmpty) {
      return const {};
    }

    Set<M> nextMatches = matches.expand((m) => getNextMatches(m)).toSet();

    Set<M> unplayableMatches =
        nextMatches.where((m) => m.isBye || m.isWalkover).toSet();

    Set<M> nextMatchesOfUnplayableMatches =
        getNextPlayableMatches(unplayableMatches);

    nextMatches.removeAll(unplayableMatches);
    nextMatches.addAll(nextMatchesOfUnplayableMatches);

    return nextMatches;
  }

  /// Returns the next match in the winner bracket.
  M? _getNextWinnerBracketMatch(
    M match,
    DoubleEliminationRound<M> roundOfMatch,
  ) {
    bool isWinnerBracketMatch =
        roundOfMatch.winnerRound?.matches.contains(match) ?? false;

    if (!isWinnerBracketMatch) {
      return null;
    }

    bool isFinal = roundOfMatch.winnerRound!.roundSize == 2 &&
        roundOfMatch.loserRound == null;

    if (isFinal) {
      return null;
    }

    bool isWinnerBracketFinal = roundOfMatch.winnerRound!.roundSize == 2;

    if (isWinnerBracketFinal) {
      return matches.last;
    }

    return winnerBracket.getNextMatch(match);
  }

  /// Returns the next match in the loser bracket.
  ///
  /// If the given [match] is from the loser bracket it returns the match that
  /// the winner advances to. When it is from the winner bracket, the returned
  /// match is the match that the loser goes to.
  M? _getNextLoserBracketMatch(
    M match,
    DoubleEliminationRound<M> roundOfMatch,
  ) {
    bool isFinal = roundOfMatch.winnerRound?.roundSize == 2 &&
        roundOfMatch.loserRound == null;

    if (isFinal) {
      return null;
    }

    int roundIndex = rounds.indexOf(roundOfMatch);

    DoubleEliminationRound<M> nextRound = rounds[roundIndex + 1];

    List<M> nextRoundMatches =
        (nextRound.loserRound ?? nextRound.winnerRound!).matches;

    return nextRoundMatches.firstWhere(
      (match) =>
          (match.a.placement!.ranking as WinnerRanking).match == match ||
          (match.b.placement!.ranking as WinnerRanking).match == match,
    );
  }
}
