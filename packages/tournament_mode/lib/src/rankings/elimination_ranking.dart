import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/modes/single_elimination.dart';
import 'package:tournament_mode/src/rankings/match_ranking.dart';
import 'package:tournament_mode/src/tournament_match.dart';

/// The ranking of a [SingleElimination] tournament round.
///
/// The participants who lost in the same round will be in tied ranks.
class EliminationRanking<P, S, M extends TournamentMatch<P, S>>
    extends TieableMatchRanking<P, S, M> {
  @override
  List<List<MatchParticipant<P>>> tiedRank() {
    List<List<MatchParticipant<P>>> ranks = rounds!.reversed
        .expand((round) => _rankRound(round))
        .where((rank) => rank.isNotEmpty)
        .toList();

    ranks = _filterHighestRanks(ranks);

    return ranks;
  }

  List<List<MatchParticipant<P>>> _rankRound(List<M> round) {
    List<_MatchRanking<P, M>> rankings =
        round.map((match) => _MatchRanking<P, M>(match: match)).toList();

    List<MatchParticipant<P>> winners =
        rankings.expand((ranking) => ranking.winner).toList();

    List<MatchParticipant<P>> losers =
        rankings.expand((ranking) => ranking.loser).toList();

    return [
      if (winners.isNotEmpty) winners,
      if (losers.isNotEmpty) losers,
    ];
  }

  /// Filter the duplicate ranks of the match rankings.
  ///
  /// Explanatory example: The [_rankRound] method ranks each elimination
  /// round independently. The ranking of a semi-final round would look
  /// something like this:
  ///
  /// ```console
  /// [
  ///   [semi-winner1, semi-winner2],
  ///   [semi-loser1, semi-loser2],
  /// ]
  /// ```
  ///
  /// Now combine that with the ranking of the final and you get this:
  ///
  /// ```console
  /// [
  ///   [final-winner],
  ///   [final-loser],
  ///   [semi-winner1, semi-winner2],
  ///   [semi-loser1, semi-loser2],
  /// ]
  /// ```
  ///
  /// Since the final participants will be the two semi-winners they are now
  /// represented twice in the overall ranking.
  ///
  /// This method removes the duplicates and only keeps the highest rank of
  /// each player. The filtered ranking looks like this:
  ///
  /// ```console
  /// [
  ///   [final-winner],
  ///   [final-loser],
  ///   [semi-loser1, semi-loser2],
  /// ]
  /// ```
  ///
  /// This would not be necessary if only a final ranking of the elimination
  /// tournament would be needed. In that case all the round winners excpept for
  /// the final winner could be omitted from the ranking.
  /// But this allows the ranking to show preliminary results before the final
  /// has beed played.
  List<List<MatchParticipant<P>>> _filterHighestRanks(
    List<List<MatchParticipant<P>>> ranks,
  ) {
    List<P> processedPlayers = [];
    List<List<MatchParticipant<P>>> filteredRanks = [];

    for (List<MatchParticipant<P>> rank in ranks) {
      List<MatchParticipant<P>> filteredRank = rank
          .where(
            (participant) =>
                !processedPlayers.contains(participant.resolvePlayer()),
          )
          .toList();

      processedPlayers.addAll(
        filteredRank.map((participant) => participant.resolvePlayer()!),
      );

      if (filteredRank.isNotEmpty) {
        filteredRanks.add(filteredRank);
      }
    }

    return filteredRanks;
  }
}

/// A ranking that categorizes the two participants of a match [M] into winners
/// and losers.
///
/// When the match is not completed yet the winner and loser lists stay empty.
///
/// It is possible that both participants are the losers when both gave a
/// walkover to each other.
class _MatchRanking<P, M extends TournamentMatch<P, dynamic>> {
  _MatchRanking({
    required this.match,
  }) {
    _rank();
  }

  final M match;

  late final List<MatchParticipant<P>> winner;
  late final List<MatchParticipant<P>> loser;

  void _rank() {
    switch (match) {
      case TournamentMatch(
          hasWinner: false,
        ):
        winner = [];
        loser = [];
        break;

      case TournamentMatch(
          isWalkover: true,
          walkoverWinner: MatchParticipant(isBye: true),
        ):
        // Double walkover case
        winner = [];
        loser = [match.a, match.b];
        break;

      default:
        P? winnerPlayer = match.getWinner()?.resolvePlayer();
        P? loserPlayer = match.getLoser()?.resolvePlayer();
        winner = [if (winnerPlayer != null) match.getWinner()!];
        loser = [if (loserPlayer != null) match.getLoser()!];
        break;
    }
  }
}
