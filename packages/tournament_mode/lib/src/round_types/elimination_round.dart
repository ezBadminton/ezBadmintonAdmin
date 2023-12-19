import 'package:tournament_mode/src/tournament_match.dart';
import 'package:tournament_mode/src/tournament_round.dart';

class EliminationRound<M extends TournamentMatch> extends TournamentRound<M> {
  EliminationRound({
    required super.matches,
    required super.tournament,
    required this.roundSize,
    this.roundDepth = 0,
    super.nestedRounds,
  });

  /// The round size is the number of participants in this [EliminationRound].
  ///
  /// `2` means final `4` means semi-final, etc.
  final int roundSize;

  /// The depth of this round.
  ///
  /// A normal elimination round has a depth of `0`.
  ///
  /// A match for 3rd place would be `1` because the participants lost once to
  /// get there and thus stepped down one level in the tournament.
  final int roundDepth;
}
