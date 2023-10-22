import 'package:collection_repository/collection_repository.dart';
import 'package:tournament_mode/tournament_mode.dart';

class BadmintonMatch extends TournamentMatch<Team, List<MatchSet>> {
  BadmintonMatch(super.a, super.b);

  /// The court that this match is/was played on.
  Court? get court => matchData?.court;

  /// This match's [MatchData] object. This is only set when the
  /// [BadmintonMatch.hydrateMatch] method was called.
  MatchData? matchData;

  /// The [Competition] that this match is a part of. The class itself does not
  /// use the value it only has to be set when the competition reference is
  /// needed for reading.
  late final Competition competition;

  /// Hydrate this match with [matchData].
  ///
  /// The [MatchData] contains administrative values about the match like
  /// [MatchData.court], [MatchData.sets] and more.
  ///
  /// The method can be called multiple times to update the [matchData].
  void hydrateMatch(MatchData matchData) {
    this.matchData = matchData;

    if (matchData.startTime != null) {
      beginMatch(matchData.startTime);
    }

    if (matchData.sets.isNotEmpty) {
      assert(matchData.endTime != null);
      setScore(matchData.sets, endTime: matchData.endTime);
    }

    walkoverWinner = switch (matchData.status) {
      MatchStatus.normal => null,
      MatchStatus.walkover1 => a,
      MatchStatus.walkover2 => b,
    };
  }

  @override
  MatchParticipant<Team>? getWinner() {
    if (walkoverWinner != null) {
      return walkoverWinner;
    }

    int aWins = 0;
    int bWins = 0;

    for (MatchSet set in score ?? []) {
      if (set.team1Points > set.team2Points) {
        aWins += 1;
      } else {
        bWins += 1;
      }
    }

    if (aWins > bWins) {
      return a;
    }
    if (bWins > aWins) {
      return b;
    }

    return null;
  }

  /// Returns an [Iterable] of all [Player]s that compete in this match that are
  /// already qualified.
  Iterable<Player> getPlayersOfMatch() {
    return [a.resolvePlayer(), b.resolvePlayer()]
        .whereType<Team>()
        .expand((team) => team.players);
  }
}
