import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/tournament_match.dart';

/// Ranks the participants of a match by who won.
class WinnerRanking<P, S> implements Ranking<P> {
  /// Creates a [WinnerRanking] from the given [match]
  const WinnerRanking(this.match);

  final TournamentMatch<P, S> match;

  @override
  List<MatchParticipant<P>> rank() {
    if (match.isBye()) {
      MatchParticipant<P> winner = match.a.isBye ? match.b : match.a;
      return [winner];
    } else if (match.isCompleted) {
      return [match.getWinner()!, match.getLoser()!];
    } else {
      return [];
    }
  }
}
