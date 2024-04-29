import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/modes/qualification_chain.dart';
import 'package:tournament_mode/src/modes/single_elimination.dart';
import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/rankings/double_elimination_ranking.dart';
import 'package:tournament_mode/src/rankings/winner_ranking.dart';
import 'package:tournament_mode/src/round_types/double_elimination_round.dart';
import 'package:tournament_mode/src/round_types/elimination_round.dart';
import 'package:tournament_mode/src/tournament_match.dart';
import 'package:tournament_mode/src/tournament_mode.dart';
import 'package:tournament_mode/src/utils.dart';

class DoubleElimination<P, S, M extends TournamentMatch<P, S>,
        E extends SingleElimination<P, S, M>> extends TournamentMode<P, S, M>
    with EliminationChain<P, S, M> {
  DoubleElimination({
    required Ranking<P> seededEntries,
    required this.singleEliminationBuilder,
  }) : winnerBracket = singleEliminationBuilder(seededEntries) {
    _createMatches();
    finalRanking = DoubleEliminationRanking(doubleEliminationTournament: this);
    matches.last.winnerRanking!.addDependantRanking(finalRanking);
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
  late final DoubleEliminationRanking<P, S, M> finalRanking;

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
        WinnerPlacement(
          ranking: match.a.placement!.ranking as WinnerRanking<P, S>,
          place: 1,
        ),
      );
      MatchParticipant<P> loser2 = MatchParticipant.fromPlacement(
        WinnerPlacement(
          ranking: match.b.placement!.ranking as WinnerRanking<P, S>,
          place: 1,
        ),
      );

      return matcher(loser1, loser2);
    }).toList();

    return firstLoserRound;
  }

  /// The intake round matches the winners of the previous loser round with the
  /// losers who come down from the winner bracket.
  /// Also called the "minor loser round".
  List<M> _createIntakeMatches(
    List<M> previousLoserRound,
    List<M> winnerRound,
  ) {
    assert(previousLoserRound.length == winnerRound.length);

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
      M loserMatch = previousLoserRound[i];
      M winnerMatch = winnerRoundMatches.elementAt(i);

      WinnerRanking<P, S> loserMatchRanking = WinnerRanking(loserMatch);
      WinnerRanking<P, S> winnerMatchRanking = winnerMatch.winnerRanking!;

      loserMatch.a.placement!.ranking.addDependantRanking(loserMatchRanking);
      loserMatch.b.placement!.ranking.addDependantRanking(loserMatchRanking);

      MatchParticipant<P> loserMatchWinner = MatchParticipant.fromPlacement(
        WinnerPlacement(ranking: loserMatchRanking, place: 0),
      );
      MatchParticipant<P> winnerMatchLoser = MatchParticipant.fromPlacement(
        WinnerPlacement(ranking: winnerMatchRanking, place: 1),
      );

      M intakeMatch = matcher(winnerMatchLoser, loserMatchWinner);

      loserMatch.nextMatches.add(intakeMatch);
      winnerMatch.nextMatches.add(intakeMatch);

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

    SingleElimination.chainMatches(intakeRound, eliminationRound);

    return eliminationRound;
  }

  M _createFinal(M loserFinal) {
    M winnerFinal = winnerBracket.matches.last;

    WinnerRanking<P, S> winnerFinalRanking = winnerFinal.winnerRanking!;
    WinnerRanking<P, S> loserFinalRanking = WinnerRanking(loserFinal);

    loserFinal.a.placement!.ranking.addDependantRanking(loserFinalRanking);
    loserFinal.b.placement!.ranking.addDependantRanking(loserFinalRanking);

    MatchParticipant<P> winnerFinalist = MatchParticipant.fromPlacement(
      WinnerPlacement(ranking: winnerFinalRanking, place: 0),
    );
    MatchParticipant<P> loserFinalist = MatchParticipant.fromPlacement(
      WinnerPlacement(ranking: loserFinalRanking, place: 0),
    );

    M finalFinal = matcher(winnerFinalist, loserFinalist);

    WinnerRanking<P, S> finalFinalRanking = WinnerRanking(finalFinal);
    winnerFinalRanking.addDependantRanking(finalFinalRanking);
    loserFinalRanking.addDependantRanking(finalFinalRanking);

    winnerFinal.nextMatches.add(finalFinal);
    loserFinal.nextMatches.add(finalFinal);

    return finalFinal;
  }
}
