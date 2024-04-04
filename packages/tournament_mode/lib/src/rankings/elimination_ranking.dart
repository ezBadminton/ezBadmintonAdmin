import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/modes/single_elimination.dart';
import 'package:tournament_mode/src/rankings/match_ranking.dart';
import 'package:tournament_mode/src/tournament_match.dart';
import 'package:tournament_mode/src/utils.dart';

/// The ranking of a [SingleElimination] tournament round.
///
/// The participants who lost in the same round will be in tied ranks.
class EliminationRanking<P, S, M extends TournamentMatch<P, S>>
    extends TieableMatchRanking<P, S, M> {
  @override
  List<List<MatchParticipant<P>>> createTiedRanks() {
    List<List<MatchParticipant<P>>> ranks = rounds!.reversed
        .expand((round) => _rankRound(round))
        .where((rank) => rank.isNotEmpty)
        .toList();

    ranks = filterHighestRanks(ranks);

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
}

/// A ranking that categorizes the two participants of a match [M] into winners
/// and losers.
///
/// When the match is not completed yet both participants count as losers. This
/// way players who have not completed a match yet are put to the bottom of
/// the ranking.
///
/// It is also possible that both participants are the losers when both gave a
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
        P? player1 = match.a.player;
        P? player2 = match.b.player;
        winner = [];
        loser = [
          if (player1 != null) match.a,
          if (player2 != null) match.b,
        ];
        break;

      case TournamentMatch(
          isWalkover: true,
          walkoverWinner: MatchParticipant(isBye: true),
        ):
        // Double walkover case
        winner = [];
        loser = [
          if (!match.a.isBye) match.a,
          if (!match.b.isBye) match.b,
        ];
        break;

      default:
        P? winnerPlayer = match.getWinner()?.player;
        P? loserPlayer = match.getLoser()?.player;
        winner = [if (winnerPlayer != null) match.getWinner()!];
        loser = [if (loserPlayer != null) match.getLoser()!];
        break;
    }
  }
}
