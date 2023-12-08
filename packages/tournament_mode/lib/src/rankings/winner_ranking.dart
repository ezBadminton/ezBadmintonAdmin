import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/tournament_match.dart';

/// Ranks the participants of a match by who won.
class WinnerRanking<P, S> extends Ranking<P> {
  /// Creates a [WinnerRanking] from the given [match]
  WinnerRanking(this.match);

  final TournamentMatch<P, S> match;

  @override
  List<MatchParticipant<P>> createRanks() {
    switch (match) {
      case TournamentMatch(
          hasWinner: true,
        ):
        MatchParticipant<P>? loser = match.getLoser();
        return [
          match.getWinner()!,
          if (loser != null) loser,
        ];

      default:
        return [];
    }
  }
}
