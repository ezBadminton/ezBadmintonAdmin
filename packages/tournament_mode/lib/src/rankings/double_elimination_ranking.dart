import 'package:tournament_mode/src/modes/double_elimination.dart';
import 'package:tournament_mode/src/rankings/elimination_ranking.dart';
import 'package:tournament_mode/src/round_types/elimination_round.dart';
import 'package:tournament_mode/src/tournament_match.dart';

/// The final ranking of a [DoubleElimination]
class DoubleEliminationRanking<P, S, M extends TournamentMatch<P, S>>
    extends EliminationRanking<P, S, M> {
  DoubleEliminationRanking({
    required this.doubleEliminationTournament,
  }) {
    _initRounds();
  }

  final DoubleElimination<P, S, M, dynamic> doubleEliminationTournament;

  void _initRounds() {
    List<EliminationRound<M>> eliminationRounds =
        doubleEliminationTournament.rounds
            .expand(
              (round) => [
                if (round.winnerRound != null) round.winnerRound!,
                if (round.loserRound != null) round.loserRound!,
              ],
            )
            .toList();

    List<List<M>> roundMatches =
        eliminationRounds.map((round) => round.matches).toList();

    initRounds(roundMatches);
  }
}
