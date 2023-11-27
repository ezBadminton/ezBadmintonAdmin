import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:tournament_mode/tournament_mode.dart';

class BadmintonRoundRobinRanking
    extends TieableMatchRanking<Team, List<MatchSet>, BadmintonMatch> {
  @override
  List<List<MatchParticipant<Team>>> tiedRank() {
    if (!ranksAvailable()) {
      return [];
    }
    List<BadmintonMatch> finishedMatches =
        matches!.where((match) => !match.isBye).toList();

    Map<Team, RoundRobinStats> stats = _createStats(finishedMatches);

    List<List<Team>> rankedByWins = _rankByStat(
      stats.keys,
      stats,
      (stats) => stats.wins,
    );

    List<List<Team>> tieBrokenRanking = rankedByWins
        .expand((tie) => _breakTie(stats, finishedMatches, tie))
        .toList();

    return tieBrokenRanking
        .map((tie) =>
            tie.map((team) => MatchParticipant.fromPlayer(team)).toList())
        .toList();
  }

  /// Ranks the [teams] by one of the values in their [stats]. The particular
  /// value to use is determined by the [statGetter].
  ///
  /// All [teams] must have an entry in the [stats] map.
  ///
  /// The returned list is descending in rank and each nested list is a rank
  /// of teams that have the same stat. More than one team in a rank means the
  /// teams are tied in the given stat.
  static List<List<Team>> _rankByStat(
    Iterable<Team> teams,
    Map<Team, RoundRobinStats> stats,
    int Function(RoundRobinStats stats) statGetter,
  ) {
    Map<int, List<Team>> statBuckets = {};

    for (Team team in teams) {
      statBuckets.update(
        statGetter(stats[team]!),
        (bucket) => bucket..add(team),
        ifAbsent: () => [team],
      );
    }

    return statBuckets.entries
        .sortedBy<num>((entry) => entry.key)
        .reversed
        .map((entry) => entry.value)
        .toList();
  }

  /// Attempts to break the [tie] between teams with the same amount of wins.
  ///
  /// All [tie]ed teams must have an entry in the [stats] map.
  ///
  /// The tie-break operates in this order:
  ///  - If the [tie] has only 2 teams it is forwarded to [_breakTwoWayTie]
  ///  - Who won more sets in all their matches (according to [stats])
  ///    - If that yields smaller ties they are recursively broken by [_breakTie]
  ///  - Who won more points in all their matches
  ///    - If that yields 2-way-ties they are broken with [_breakTwoWayTie]
  ///
  /// The returned list is descending in rank and each nested list is a rank
  /// of teams. More than one team in a rank means the tie could not be fully
  /// broken.
  static List<List<Team>> _breakTie(
    Map<Team, RoundRobinStats> stats,
    List<BadmintonMatch> matches,
    List<Team> tie,
  ) {
    assert(tie.isNotEmpty);
    if (tie.length == 1) {
      return [tie];
    }
    if (tie.length == 2) {
      return _breakTwoWayTie(stats, matches, tie[0], tie[1]);
    }

    // 1st attempt: Rank by overall set wins
    List<List<Team>> ranks =
        _rankByStat(tie, stats, (stats) => stats.setDifference);

    if (ranks.length > 1) {
      // Break the sub-ties
      ranks = ranks.expand((tie) => _breakTie(stats, matches, tie)).toList();
      return ranks;
    }

    // 2nd attempt: Rank by overall point wins
    ranks = _rankByStat(tie, stats, (stats) => stats.pointDifference);

    // Break any remaining 2-way-ties. Still remaining ties are unbreakable.
    ranks = ranks
        .expand((tie) => switch (tie.length) {
              2 => _breakTie(stats, matches, tie),
              _ => [tie],
            })
        .toList();

    return ranks;
  }

  /// Attempts to break a two-way-tie between [team1] and [team2].
  ///
  /// Both teams must have an entry in the [stats] map.
  ///
  /// The tie-break operates in this order:
  ///
  /// Who won more...
  ///  - direct encounters (inside [matches])
  ///  - sets in the direct encounters
  ///  - points in the direct encounters
  ///  - sets in all their matches (according to [stats])
  ///  - points in all their matches
  ///
  /// If none of those criteria are decisive the tie is unbreakable and
  /// `[[team1, team2]]` is returned. Otherwise `[[winner],[loser]]`.
  static List<List<Team>> _breakTwoWayTie(
    Map<Team, RoundRobinStats> stats,
    List<BadmintonMatch> matches,
    Team team1,
    Team team2,
  ) {
    List<Team> tie = [team1, team2];
    List<BadmintonMatch> directMatches = _getDirectMatches(
      matches,
      team1,
      team2,
    );

    Map<Team, RoundRobinStats> directStats = _createStats(directMatches);

    // 1st attempt: Rank by direct match wins
    List<List<Team>> ranks =
        _rankByStat(tie, directStats, (stats) => stats.wins);
    if (ranks.length == 2) {
      return ranks;
    }

    // 2nd attempt: Rank by direct set wins
    ranks = _rankByStat(tie, directStats, (stats) => stats.setDifference);
    if (ranks.length == 2) {
      return ranks;
    }

    // 3nd attempt: Rank by direct point wins
    ranks = _rankByStat(tie, directStats, (stats) => stats.pointDifference);
    if (ranks.length == 2) {
      return ranks;
    }

    // 4th attempt: Rank by overall set wins
    ranks = _rankByStat(tie, stats, (stats) => stats.setDifference);
    if (ranks.length == 2) {
      return ranks;
    }

    // 5th attempt: Rank by overall point wins
    ranks = _rankByStat(tie, stats, (stats) => stats.pointDifference);

    // If tie could not be broken return a tied ranking
    return ranks;
  }

  static List<BadmintonMatch> _getDirectMatches(
    List<BadmintonMatch> matches,
    Team team1,
    Team team2,
  ) {
    return matches.where((match) {
      Team matchParticipant1 = match.a.resolvePlayer()!;
      Team matchParticipant2 = match.b.resolvePlayer()!;

      return (team1 == matchParticipant1 && team2 == matchParticipant2) ||
          (team1 == matchParticipant2 && team2 == matchParticipant1);
    }).toList();
  }

  static Map<Team, RoundRobinStats> _createStats(List<BadmintonMatch> matches) {
    Map<Team, int> numMatches = _countMatches(matches);
    Map<Team, int> wins = _countWins(matches);
    Map<Team, ({int wins, int losses})> sets = _countSets(matches);
    Map<Team, ({int wins, int losses})> points = _countPoints(matches);

    Map<Team, RoundRobinStats> stats = {
      for (Team team in numMatches.keys)
        team: RoundRobinStats(
          numMatches: numMatches[team]!,
          wins: wins[team]!,
          setsWon: sets[team]!.wins,
          setsLost: sets[team]!.losses,
          pointsWon: points[team]!.wins,
          pointsLost: points[team]!.losses,
        ),
    };

    return stats;
  }

  static Map<Team, int> _countMatches(List<BadmintonMatch> matches) {
    Map<Team, int> numMatches = {};

    for (BadmintonMatch match in matches) {
      Team team1 = match.a.resolvePlayer()!;
      Team team2 = match.b.resolvePlayer()!;

      numMatches.update(team1, (amount) => amount + 1, ifAbsent: () => 1);
      numMatches.update(team2, (amount) => amount + 1, ifAbsent: () => 1);
    }

    return numMatches;
  }

  static Map<Team, int> _countWins(List<BadmintonMatch> matches) {
    Map<Team, int> wins = {};

    for (BadmintonMatch match in matches) {
      Team? winner = match.getWinner()?.resolvePlayer();
      Team? loser = match.getLoser()?.resolvePlayer();

      if (winner != null && loser != null) {
        wins.update(winner, (wins) => wins + 1, ifAbsent: () => 1);
        wins.putIfAbsent(loser, () => 0);
      } else {
        Team? team1 = match.a.resolvePlayer();
        Team? team2 = match.b.resolvePlayer();

        if (team1 != null) {
          wins.putIfAbsent(team1, () => 0);
        }
        if (team2 != null) {
          wins.putIfAbsent(team2, () => 0);
        }
      }
    }

    return wins;
  }

  static Map<Team, ({int wins, int losses})> _countSets(
    List<BadmintonMatch> matches,
  ) {
    Map<Team, ({int wins, int losses})> setWins = {};

    for (BadmintonMatch match in matches) {
      Team team1 = match.a.resolvePlayer()!;
      Team team2 = match.b.resolvePlayer()!;
      for (MatchSet set in match.score!) {
        bool team1Win = set.team1Points > set.team2Points;
        Team winner = team1Win ? team1 : team2;
        Team loser = team1Win ? team2 : team1;

        setWins.update(
          winner,
          (stats) => (wins: stats.wins + 1, losses: stats.losses),
          ifAbsent: () => (wins: 1, losses: 0),
        );
        setWins.update(
          loser,
          (stats) => (wins: stats.wins, losses: stats.losses + 1),
          ifAbsent: () => (wins: 0, losses: 1),
        );
      }
    }

    return setWins;
  }

  static Map<Team, ({int wins, int losses})> _countPoints(
    List<BadmintonMatch> matches,
  ) {
    Map<Team, ({int wins, int losses})> points = {};

    for (BadmintonMatch match in matches) {
      Team team1 = match.a.resolvePlayer()!;
      Team team2 = match.b.resolvePlayer()!;
      for (MatchSet set in match.score!) {
        int points1 = set.team1Points;
        int points2 = set.team2Points;

        points.update(
          team1,
          (stats) =>
              (wins: stats.wins + points1, losses: stats.losses + points2),
          ifAbsent: () => (wins: points1, losses: points2),
        );
        points.update(
          team2,
          (stats) =>
              (wins: stats.wins + points2, losses: stats.losses + points1),
          ifAbsent: () => (wins: points2, losses: points1),
        );
      }
    }

    return points;
  }
}

class RoundRobinStats {
  RoundRobinStats({
    required this.numMatches,
    required this.wins,
    required this.setsWon,
    required this.setsLost,
    required this.pointsWon,
    required this.pointsLost,
  });

  final int numMatches;
  final int wins;
  final int setsWon;
  final int setsLost;
  final int pointsWon;
  final int pointsLost;

  int get losses => numMatches - wins;
  int get setDifference => setsWon - setsLost;
  int get pointDifference => pointsWon - pointsLost;
}
