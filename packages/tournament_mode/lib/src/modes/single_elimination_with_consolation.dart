import 'dart:math';

import 'package:tournament_mode/src/rankings/consolation_ranking.dart';
import 'package:tournament_mode/tournament_mode.dart';
import 'package:tournament_mode/src/utils.dart' as utils;

class SingleEliminationWithConsolation<P, S, M extends TournamentMatch<P, S>,
    E extends SingleElimination<P, S, M>> extends TournamentMode<P, S, M> {
  SingleEliminationWithConsolation({
    required Ranking<P> seededEntries,
    required this.singleEliminationBuilder,
    this.placesToPlayOut = 2,
    this.numConsolationRounds = 0,
  })  : _entries = seededEntries,
        _finalRanking = EliminationRanking() {
    _createMatches();
    _initFinalRanking();
  }

  final E Function(Ranking<P> entries) singleEliminationBuilder;

  late final E mainElimination;

  late final BracketWithConsolation<P, S, M, E> mainBracket;

  late final List<BracketWithConsolation<P, S, M, E>> allBrackets;

  /// The tournament will always have the minimum amount of consolation rounds
  /// to play out all [placesToPlayOut] without ties.
  ///
  /// More rounds can be added if [numConsolationRounds] is set to something
  /// higher than required for the places.
  final int placesToPlayOut;

  /// The number of consolation rounds sets how many times a participant goes
  /// down to the next consolation round after losing a match that is not a
  /// final. Each participant is thus guaranteed [numConsolationRounds] + 1
  /// matches.
  ///
  /// If the [numConsolationRounds] does not cover the [placesToPlayOut] then
  /// more consolation rounds are added until all places can be played out.
  final int numConsolationRounds;

  final Ranking<P> _entries;
  @override
  Ranking<P> get entries => _entries;

  final EliminationRanking<P, S, M> _finalRanking;
  @override
  EliminationRanking<P, S, M> get finalRanking => _finalRanking;

  late final List<List<EliminationRound<M>>> roundGroups;

  @override
  late final List<EliminationRound<M>> rounds;

  @override
  List<M> get matches =>
      [for (EliminationRound<M> round in rounds) ...round.matches];

  void _createMatches() {
    mainElimination = singleEliminationBuilder(entries);

    List<BracketWithConsolation<P, S, M, E>> allBrackets = [];
    List<BracketWithConsolation<P, S, M, E>> consolationRounds =
        _createConsolationBrackets(mainElimination, 0, allBrackets);

    mainBracket = BracketWithConsolation(
      bracket: mainElimination,
      consolationBrackets: consolationRounds,
    );

    allBrackets.add(mainBracket);

    this.allBrackets = allBrackets.reversed.toList();
    _arrangeRounds();
  }

  /// The rounds are arranged such that the winner bracket matches are always
  /// ordered in front of the consolation matches.
  void _arrangeRounds() {
    roundGroups = _groupRoundsBySize(mainBracket, {});

    List<EliminationRound<M>> rounds = roundGroups.map(
      (roundGroup) {
        List<M> matches = roundGroup.expand((round) => round.matches).toList();

        List<EliminationRound<M>> nestedRounds = [];
        if (roundGroup.length > 1) {
          nestedRounds = roundGroup;
        }

        EliminationRound<M> round = EliminationRound<M>(
          matches: matches,
          tournament: this,
          roundSize: roundGroup.first.roundSize,
          nestedRounds: nestedRounds,
        );

        for (M match in matches) {
          match.round = round;
        }

        return round;
      },
    ).toList();

    this.rounds = rounds;
  }

  /// Recursively collects all rounds of the same size.
  ///
  /// This way all finals, semi-finals, quarter-finals, etc. end up in one list.
  ///
  /// The lists are ordered with the winner-bracket's round in front, followed
  /// by all consolation rounds in descending order of their ranking.
  /// For example the match for 3rd place comes before the final of the
  /// consolation bracket for 5th place.
  List<List<EliminationRound<M>>> _groupRoundsBySize(
    BracketWithConsolation<P, S, M, E> consolationBracket,
    Map<int, List<EliminationRound<M>>> result,
  ) {
    for (EliminationRound<M> round in consolationBracket.bracket.rounds) {
      result.update(
        round.roundSize,
        (roundList) => roundList..add(round),
        ifAbsent: () => [round],
      );
    }

    for (BracketWithConsolation<P, S, M, E> bracket
        in consolationBracket.consolationBrackets.reversed) {
      _groupRoundsBySize(bracket, result);
    }

    return result.values.toList();
  }

  /// Recursively creates the consolation brackets until [numConsolationRounds]
  /// is reached.
  ///
  /// If the [winnerBracket] only has one match then the recursion quietly stops
  /// even if [numConsolationRounds] has not been reached.
  List<BracketWithConsolation<P, S, M, E>> _createConsolationBrackets(
    E winnerBracket,
    int depth,
    List<BracketWithConsolation<P, S, M, E>> allBrackets,
  ) {
    int numConsolationRounds = this.numConsolationRounds - depth;

    int finalsInBracket = allBrackets.length + depth + 1;
    int placesToPlayOut = this.placesToPlayOut - finalsInBracket * 2;

    List<BracketWithConsolation<P, S, M, E>> consolationRounds = [];
    if (numConsolationRounds <= 0 && placesToPlayOut <= 0) {
      return consolationRounds;
    }

    // The first round is always skipped because it has no equivalent
    // consolation round
    int skipConsolations = 1;

    if (numConsolationRounds <= 0) {
      int numWinnerRounds = winnerBracket.rounds.length;

      int numFinalsRequired = (placesToPlayOut / 2).ceil();
      int numRoundsRequired = _getNumBracketsForFinals(numFinalsRequired);

      skipConsolations = numWinnerRounds - numRoundsRequired;

      skipConsolations = max(1, skipConsolations);
    }

    Iterable<EliminationRound<M>> roundsToConsole =
        winnerBracket.rounds.skip(skipConsolations).toList().reversed;

    for (EliminationRound<M> round in roundsToConsole) {
      E consolationElimination = _createConsolationTournament(round);

      List<BracketWithConsolation<P, S, M, E>> nestedConsolationBrackes =
          _createConsolationBrackets(
        consolationElimination,
        depth + 1,
        allBrackets,
      );

      BracketWithConsolation<P, S, M, E> consolationBracket =
          BracketWithConsolation(
        bracket: consolationElimination,
        consolationBrackets: nestedConsolationBrackes,
      );

      allBrackets.add(consolationBracket);
      consolationRounds.insert(0, consolationBracket);
    }

    return consolationRounds;
  }

  /// Make an elimination tournament that is derived from the given
  /// [round] in the winner bracket.
  ///
  /// For example when the given [round] is the semi-final round of the winner
  /// bracket, then the returned tournament's entries are the 4 participants
  /// who missed the semi-final qualification because they lost their
  /// quarter-final. The tournament can be seen as the "loser-equivalent" of
  /// the given [round].
  E _createConsolationTournament(EliminationRound<M> round) {
    List<MatchParticipant<P>> losers = round.matches
        .expand(
      (match) => [match.a.placement!.ranking, match.b.placement!.ranking],
    )
        .map(
      (ranking) {
        WinnerRanking<P, S> winnerRanking = ranking as WinnerRanking<P, S>;

        Placement<P> loserPlacement =
            Placement(ranking: winnerRanking, place: 1);

        return MatchParticipant.fromPlacement(loserPlacement);
      },
    ).toList();

    Ranking<P> loserRoundEntries = ConsolationRanking(losers);

    return singleEliminationBuilder(loserRoundEntries);
  }

  void _initFinalRanking() {
    List<List<M>> roundMatches = roundGroups
        .expand(
          (roundGroup) =>
              roundGroup.reversed.map((round) => round.matches).toList(),
        )
        .toList();

    finalRanking.initRounds(roundMatches);
  }

  @override
  List<M> getEditableMatches() {
    List<M> editableMatches = matches
        .where((match) => match.hasWinner && !match.isWalkover && !match.isBye)
        .where((match) {
      Set<M> nextMatches = getNextPlayableMatches([match]);

      bool areNextMatchesFinished = nextMatches.fold(
        false,
        (finished, match) => finished || match.hasWinner,
      );

      return !areNextMatchesFinished;
    }).toList();

    return editableMatches;
  }

  @override
  List<M> withdrawPlayer(P player) {
    return allBrackets
        .expand((bracket) => bracket.bracket.withdrawPlayer(player))
        .toList();
  }

  @override
  List<M> reenterPlayer(P player) {
    List<M> reenteringMatches = allBrackets
        .expand((bracket) => bracket.bracket.reenterPlayer(player))
        .toList();

    List<M> validReenteringMatches = reenteringMatches.where(
      (match) {
        Set<M> nextMatches = getNextPlayableMatches([match]);

        bool areNextMatchesInProgress = nextMatches.fold(
          false,
          (inProgress, match) => inProgress || match.startTime != null,
        );

        return !areNextMatchesInProgress;
      },
    ).toList();

    return validReenteringMatches;
  }

  /// Returns the matches that the winner/loser of the [match] qualify for.
  ///
  /// When the returned List contains 2 matches, the first one is the match
  /// that the winner qualifies for and the second is the one that the loser
  /// qualifies for.
  /// If it is only one match then the loser of the [match] is out.
  /// When the returned list is empty, the given [match] was a final.
  List<M> getNextMatches(M match) {
    EliminationRound<M> roundOfMatch = match.round as EliminationRound<M>;

    int roundIndex = rounds.indexOf(roundOfMatch);

    EliminationRound<M>? nextRound = rounds.elementAtOrNull(roundIndex + 1);
    if (nextRound == null) {
      return [];
    }

    List<M> nextMatches = nextRound.matches
        .where(
          (m) =>
              (m.a.placement!.ranking as WinnerRanking).match == match ||
              (m.b.placement!.ranking as WinnerRanking).match == match,
        )
        .toList();

    return nextMatches;
  }

  /// Returns the matches in the qualification chain of the given [matches] that
  /// are not a bye or a walkover.
  Set<M> getNextPlayableMatches(Iterable<M> matches) {
    return utils.getNextPlayableMatches(
      matches,
      getNextMatches: getNextMatches,
    );
  }

  /// Calculates the amount of brackets that need to be played with full
  /// consolation to produce the desired amount of final rounds, [numFinals].
  ///
  /// For [numFinals] = 1 it is just one bracket that has one match.
  /// Each extra bracket always has one extra stage and this produces one more
  /// final than the bracket before it.
  ///
  /// The function's values thus look like this:
  /// 1 -> 1
  /// 2 -> 2
  /// 3 -> 2
  /// 4 -> 3
  /// 5 -> 3
  /// 6 -> 3
  /// ... (it's one 1, two 2's, three 3's, etc.)
  ///
  /// For example, to get 2 or 3 finals, 2 brackets are needed because the first
  /// bracket produces 2 finals by having a final and a match for 3rd place and
  /// the 2nd bracket is just a final.
  ///
  /// This problem has been discussed:
  /// https://math.stackexchange.com/questions/455511/formula-for-the-nth-term-of-1-2-2-3-3-3-4-4-4-4-5
  ///
  /// This uses the O(n) integer math solution instead of the O(1) floating
  /// point arithmetic solution because [numFinals] will never be very big and
  /// the integer math is free of potential rounding errors.
  static int _getNumBracketsForFinals(int numFinals) {
    int i = 0;

    int numBrackets = 0;
    while (i < numFinals) {
      numBrackets += 1;

      for (int n = 0; n < numBrackets; n += 1) {
        i += 1;
        if (i >= numFinals) {
          return numBrackets;
        }
      }
    }

    return numBrackets;
  }
}

class BracketWithConsolation<P, S, M extends TournamentMatch<P, S>,
    E extends SingleElimination<P, S, M>> {
  BracketWithConsolation({
    required this.bracket,
    required this.consolationBrackets,
  });

  final E bracket;

  final List<BracketWithConsolation<P, S, M, E>> consolationBrackets;
}
