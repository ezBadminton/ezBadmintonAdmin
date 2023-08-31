import 'package:tournament_mode/src/tournament_round.dart';

class RoundRobinRound<P, S> extends TournamentRound<P, S> {
  RoundRobinRound({
    required super.roundMatches,
    required this.roundNumber,
    required this.totalRounds,
    super.nestedRounds,
  });

  final int roundNumber;
  final int totalRounds;
}
