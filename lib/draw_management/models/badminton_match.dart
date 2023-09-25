import 'package:collection_repository/collection_repository.dart';
import 'package:tournament_mode/tournament_mode.dart';

class BadmintonMatch extends TournamentMatch<Team, List<MatchSet>> {
  BadmintonMatch(super.a, super.b);

  @override
  MatchParticipant<Team>? getWinner() {
    int aWins = 0;
    int bWins = 0;

    for (MatchSet set in score ?? []) {
      if (set.team1Points > set.team2Points) {
        aWins += 1;
      } else {
        bWins += 1;
      }
    }

    if (aWins == 2) {
      return a;
    }
    if (bWins == 2) {
      return b;
    }

    return null;
  }
}
