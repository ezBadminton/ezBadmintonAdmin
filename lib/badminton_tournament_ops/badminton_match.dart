import 'package:collection_repository/collection_repository.dart';
import 'package:tournament_mode/tournament_mode.dart';

class BadmintonMatch extends TournamentMatch<Team, List<MatchSet>> {
  BadmintonMatch(super.a, super.b);

  /// The court that this match is/was played on.
  Court? get court => matchData?.court;

  /// This match's [MatchData] object. This is only set when the
  /// [BadmintonMatch.hydrateMatch] method was called.
  MatchData? matchData;

  Competition? _competition;

  /// The [Competition] that this match is a part of. This is only set when the
  /// [BadmintonMatch.hydrateMatch] method was called.
  Competition get competition => _competition!;

  /// Hydrate this match with [matchData].
  ///
  /// The [MatchData] contains administrative values about the match like
  /// [MatchData.court], [MatchData.sets] and more.
  ///
  /// The method can be called multiple times to update the [matchData].
  void hydrateMatch(Competition competition, MatchData? matchData) {
    resetMatch();

    _competition = competition;
    this.matchData = matchData;

    if (matchData == null) {
      return;
    }

    if (matchData.startTime != null) {
      beginMatch(matchData.startTime);
    }

    withdrawnParticipants = _getWithdrawnParticipants();

    if (matchData.sets.isEmpty &&
        walkoverWinner == null &&
        matchData.endTime != null) {
      endMatch(matchData.endTime!);
    }

    if (matchData.sets.isNotEmpty && walkoverWinner == null) {
      assert(matchData.endTime != null);
      setScore(matchData.sets, endTime: matchData.endTime);
    }

    if (walkoverWinner != null) {
      setScore(_createWalkoverScore(), endTime: matchData.endTime);
    }
  }

  List<MatchParticipant<Team>>? _getWithdrawnParticipants() {
    if (matchData!.withdrawnTeams.isEmpty) {
      return null;
    }

    List<MatchParticipant<Team>> withdrawnParticipants = [a, b]
        .where(
          (participant) =>
              matchData!.withdrawnTeams.contains(participant.player),
        )
        .toList();

    return withdrawnParticipants;
  }

  List<MatchSet> _createWalkoverScore() {
    assert(walkoverWinner != null);

    int winningSets = competition.tournamentModeSettings!.winningSets;
    int winningPoints = competition.tournamentModeSettings!.winningPoints;

    int winnerIndex = [a, b].indexOf(walkoverWinner!);

    if (walkoverWinner!.isBye) {
      winnerIndex = -1;
    }

    List<MatchSet> walkoverScore = List.generate(
      winningSets,
      (_) => switch (winnerIndex) {
        0 => MatchSet.newMatchSet(team1Points: winningPoints, team2Points: 0),
        1 => MatchSet.newMatchSet(team1Points: 0, team2Points: winningPoints),
        // Both players withdrew from the match
        _ => MatchSet.newMatchSet(team1Points: 0, team2Points: 0),
      },
    );

    return walkoverScore;
  }

  @override
  MatchParticipant<Team>? getWinner() {
    if (walkoverWinner != null) {
      return walkoverWinner;
    }

    if (byeWinner != null) {
      return byeWinner;
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
    return [a.player, b.player]
        .whereType<Team>()
        .expand((team) => team.players);
  }

  @override
  String getPlayerFingerprint(Team? player) {
    if (player == null) {
      return "noplayer";
    }

    return [for (Player p in player.players) p.id].join(':');
  }

  @override
  String getScoreFingerprint(List<MatchSet>? score) {
    if (score == null) {
      return "noscore";
    }

    String fingerprint = score
        .map(
          (s) => '${s.team1Points}:${s.team2Points}',
        )
        .join('-');

    return fingerprint;
  }
}
