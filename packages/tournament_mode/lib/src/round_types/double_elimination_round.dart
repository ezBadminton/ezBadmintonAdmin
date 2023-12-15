import 'package:tournament_mode/src/round_types/round_types.dart';
import 'package:tournament_mode/src/tournament_match.dart';
import 'package:tournament_mode/src/tournament_round.dart';

class DoubleEliminationRound<M extends TournamentMatch>
    extends TournamentRound<M> {
  DoubleEliminationRound({
    required super.tournament,
    this.winnerRound,
    this.loserRound,
  }) : super(
          matches: _createMatchList(
            winnerRound: winnerRound,
            loserRound: loserRound,
          ),
          nestedRounds: [
            if (winnerRound != null) winnerRound,
            if (loserRound != null) loserRound,
          ],
        ) {
    Iterable<M> matches =
        (winnerRound?.matches ?? []).followedBy(loserRound?.matches ?? []);

    for (M match in matches) {
      match.round = this;
    }
  }

  final EliminationRound<M>? winnerRound;
  final EliminationRound<M>? loserRound;

  static List<M> _createMatchList<M extends TournamentMatch>({
    EliminationRound<M>? winnerRound,
    EliminationRound<M>? loserRound,
  }) {
    if (winnerRound == null) {
      return loserRound!.matches;
    }
    if (loserRound == null) {
      return winnerRound.matches;
    }

    assert(winnerRound.matches.length == loserRound.matches.length);

    return [
      for (int i = 0; i < winnerRound.length; i += 1) ...[
        winnerRound.matches[i],
        loserRound.matches[i],
      ]
    ];
  }
}
