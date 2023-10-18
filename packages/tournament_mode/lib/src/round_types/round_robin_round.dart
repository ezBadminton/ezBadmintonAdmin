import 'package:tournament_mode/src/tournament_match.dart';
import 'package:tournament_mode/src/tournament_round.dart';

class RoundRobinRound<M extends TournamentMatch> extends TournamentRound<M> {
  RoundRobinRound({
    required super.matches,
    required super.tournament,
    required this.roundNumber,
    required this.totalRounds,
    super.nestedRounds,
  });

  final int roundNumber;
  final int totalRounds;
}
