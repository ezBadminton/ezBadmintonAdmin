import 'dart:math';

import 'package:tournament_mode/src/modes/qualification_chain.dart';
import 'package:tournament_mode/src/rankings/consolation_ranking.dart';
import 'package:tournament_mode/tournament_mode.dart';

class SingleEliminationWithConsolation<P, S, M extends TournamentMatch<P, S>,
        E extends SingleElimination<P, S, M>> extends TournamentMode<P, S, M>
    with EliminationChain<P, S, M> {
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
  /// is reached and [placesToPlayOut] is satisfied.
  ///
  /// If the [winnerBracket] only has one match then the recursion quietly stops
  /// even if [numConsolationRounds] or [placesToPlayOut] has not been reached.
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

    // Iterate in reverse round order to go from the highest level consolation
    // round (match for 3rd place) to the lowest (losers of first round).
    // This needs to be done to be able to keep count of the played out places
    // via the [allBrackets] list since those are counted from the highest
    // places downwards.
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

  /// Make a consolation elimination tournament that is derived from the given
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
            WinnerPlacement(ranking: winnerRanking, place: 1);

        return MatchParticipant.fromPlacement(loserPlacement);
      },
    ).toList();

    Ranking<P> loserRoundEntries = ConsolationRanking(losers);

    E consolationTournament = singleEliminationBuilder(loserRoundEntries);

    int roundIndex = round.tournament.rounds.indexOf(round);
    TournamentRound<M> previousRound = round.tournament.rounds[roundIndex - 1];
    SingleElimination.chainMatches(
      previousRound.matches,
      consolationTournament.rounds.first.matches,
    );

    return consolationTournament;
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
