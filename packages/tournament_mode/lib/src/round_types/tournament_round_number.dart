/// The generic number of a round in a tournament mode
///
/// See also:
/// * [TournamentRound] where this can be used as [TournamentRound.roundId]
class TournamentRoundNumber {
  const TournamentRoundNumber({
    required this.roundNumber,
    required this.totalRounds,
  });

  final int roundNumber;
  final int totalRounds;
}
