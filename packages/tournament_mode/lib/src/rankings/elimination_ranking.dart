import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/modes/single_elimination.dart';
import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/rankings/match_ranking.dart';
import 'package:tournament_mode/src/rankings/winner_ranking.dart';
import 'package:tournament_mode/src/tournament_match.dart';

/// The ranking of a [SingleElimination] tournament round.
///
/// The ranks 1-2 are the only definite placements as the result of the final.
/// 3-4 are both losers of the semi-finals and thus have the same rank, etc...
class EliminationRanking<P, S> extends MatchRanking<P, S> {
  List<List<WinnerRanking<P, S>>> get _roundResults =>
      rounds!.map(_getRoundResults).toList();

  List<MatchParticipant<P>?>? _ranks;

  @override
  void initRounds(List<List<TournamentMatch<P, S>>> rounds) {
    super.initRounds(rounds);
    _ranks = [
      for (List<WinnerRanking<P, S>> roundResult in _roundResults.reversed) ...[
        // Winner of final
        if (roundResult.length == 1)
          MatchParticipant.fromPlacement(
            Placement(ranking: roundResult[0], place: 0),
          ),
        // Losers of round
        for (WinnerRanking<P, S> result in roundResult)
          if (!result.match.isBye())
            MatchParticipant.fromPlacement(
              Placement(ranking: result, place: 1),
            ),
      ],
    ];
  }

  @override
  List<MatchParticipant<P>?> rank() => _ranks!;

  List<WinnerRanking<P, S>> _getRoundResults(
    List<TournamentMatch<P, S>> round,
  ) {
    return round.map((match) => WinnerRanking(match)).toList();
  }
}
