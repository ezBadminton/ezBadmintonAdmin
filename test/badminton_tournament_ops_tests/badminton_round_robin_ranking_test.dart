import 'dart:math';

import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_round_robin_ranking.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tournament_mode/tournament_mode.dart';

class HasRankOccupant extends CustomMatcher {
  HasRankOccupant(
    matcher, {
    required this.rank,
  }) : super(
          'Ranking with Player on rank $rank',
          'Player on rank',
          matcher,
        );

  final int rank;

  @override
  featureValueOf(actual) => actual[rank]?.resolvePlayer()?.players[0];
}

void main() {
  List<Player> players = List.generate(
    10,
    (index) => Player.newPlayer().copyWith(id: 'player-$index'),
  );

  List<Team> createTeams(List<Player> players) => players
      .map(
        (player) =>
            Team.newTeam(players: [player]).copyWith(id: 'team-${player.id}'),
      )
      .toList();

  RoundRobin<Team, List<MatchSet>, BadmintonMatch> createTournament(
      int numParticipants,
      [int passes = 1]) {
    assert(numParticipants >= 2 && numParticipants <= 10);
    return RoundRobin(
      entries: DrawSeeds(createTeams(players.sublist(0, numParticipants))),
      finalRanking: BadmintonRoundRobinRanking(),
      passes: passes,
      matcher: (MatchParticipant<Team> a, MatchParticipant<Team> b) =>
          BadmintonMatch(a, b),
    );
  }

  MatchSet createSet((int, int) score) {
    Random random = Random();

    return MatchSet(
      id: 'matchset-${random.nextInt(999999999)}',
      created: DateTime.now(),
      updated: DateTime.now(),
      team1Points: score.$1,
      team2Points: score.$2,
    );
  }

  List<MatchSet> createSets(
    (int, int) score1,
    (int, int) score2, [
    (int, int)? score3,
  ]) {
    return [
      createSet(score1),
      createSet(score2),
      if (score3 != null) createSet(score3),
    ];
  }

  void arrangeScore(
    Player player1,
    Player player2,
    (int, int) score1,
    (int, int) score2,
    (int, int)? score3,
    List<BadmintonMatch> matches, {
    int matchIndex = 0,
  }) {
    BadmintonMatch match = matches.where((m) {
      Player? opponent1 = m.a.resolvePlayer()?.players[0];
      Player? opponent2 = m.b.resolvePlayer()?.players[0];

      return (opponent1 == player1 && opponent2 == player2) ||
          (opponent1 == player2 && opponent2 == player1);
    }).elementAt(matchIndex);

    if (match.a.resolvePlayer()!.players[0] == player2) {
      score1 = (score1.$2, score1.$1);
      score2 = (score2.$2, score2.$1);
      if (score3 != null) {
        score3 = (score3.$2, score3.$1);
      }
    }

    match.score = createSets(score1, score2, score3);
  }

  test('inital ranking is empty', () {
    RoundRobin<Team, List<MatchSet>, BadmintonMatch> tournament =
        createTournament(3);
    BadmintonRoundRobinRanking sut =
        tournament.finalRanking as BadmintonRoundRobinRanking;

    expect(sut.rank(), isEmpty);
  });

  test('three-way-tie', () {
    RoundRobin<Team, List<MatchSet>, BadmintonMatch> tournament =
        createTournament(3);
    BadmintonRoundRobinRanking sut =
        tournament.finalRanking as BadmintonRoundRobinRanking;

    List<BadmintonMatch> matches = tournament.matches;

    // 0 wins vs 1
    arrangeScore(players[0], players[1], (21, 0), (21, 0), null, matches);
    // 1 wins vs 2
    arrangeScore(players[1], players[2], (21, 0), (21, 0), null, matches);
    // 2 wins vs 0
    arrangeScore(players[2], players[0], (21, 0), (21, 0), null, matches);

    expect(sut.rank(), hasLength(3));
    expect(sut.tiedRank(), hasLength(1));
  });

  test('three-way tie-break via overall sets', () {
    RoundRobin<Team, List<MatchSet>, BadmintonMatch> tournament =
        createTournament(3);
    BadmintonRoundRobinRanking sut =
        tournament.finalRanking as BadmintonRoundRobinRanking;

    List<BadmintonMatch> matches = tournament.matches;

    // 0 wins vs 1 in 3 sets
    arrangeScore(players[0], players[1], (21, 0), (0, 21), (21, 0), matches);
    // 1 wins vs 2
    arrangeScore(players[1], players[2], (21, 0), (21, 0), null, matches);
    // 2 wins vs 0
    arrangeScore(players[2], players[0], (21, 0), (21, 0), null, matches);

    expect(sut.rank(), hasLength(3));
    expect(sut.tiedRank(), hasLength(3));

    expect(sut.rank(), HasRankOccupant(players[1], rank: 0));
    expect(sut.rank(), HasRankOccupant(players[2], rank: 1));
    expect(sut.rank(), HasRankOccupant(players[0], rank: 2));
  });

  test('three-way tie-break via overall points', () {
    RoundRobin<Team, List<MatchSet>, BadmintonMatch> tournament =
        createTournament(3);
    BadmintonRoundRobinRanking sut =
        tournament.finalRanking as BadmintonRoundRobinRanking;

    List<BadmintonMatch> matches = tournament.matches;

    // 0 wins vs 1 with points to 1
    arrangeScore(players[0], players[1], (21, 1), (21, 0), null, matches);
    // 1 wins vs 2
    arrangeScore(players[1], players[2], (21, 0), (21, 0), null, matches);
    // 2 wins vs 0
    arrangeScore(players[2], players[0], (21, 0), (21, 0), null, matches);

    expect(sut.rank(), hasLength(3));
    expect(sut.tiedRank(), hasLength(3));

    expect(sut.rank(), HasRankOccupant(players[1], rank: 0));
    expect(sut.rank(), HasRankOccupant(players[2], rank: 1));
    expect(sut.rank(), HasRankOccupant(players[0], rank: 2));
  });

  test('three-way tie-break via points and direct comparison', () {
    RoundRobin<Team, List<MatchSet>, BadmintonMatch> tournament =
        createTournament(4);
    BadmintonRoundRobinRanking sut =
        tournament.finalRanking as BadmintonRoundRobinRanking;

    List<BadmintonMatch> matches = tournament.matches;

    // 0 wins vs 1 in 3 sets
    arrangeScore(players[0], players[1], (21, 0), (0, 21), (21, 0), matches);
    // 0 wins vs 2 in 3 sets and points to 2
    arrangeScore(players[0], players[2], (21, 19), (0, 21), (21, 19), matches);
    // 0 wins vs 3 in 3 sets
    arrangeScore(players[0], players[3], (21, 0), (0, 21), (21, 0), matches);
    // 1 wins vs 2
    arrangeScore(players[1], players[2], (21, 0), (21, 0), null, matches);
    // 2 wins vs 3
    arrangeScore(players[2], players[3], (21, 0), (21, 0), null, matches);
    // 3 wins vs 1
    arrangeScore(players[3], players[1], (21, 0), (21, 0), null, matches);

    expect(sut.rank(), hasLength(4));
    expect(sut.tiedRank(), hasLength(4));

    expect(sut.rank(), HasRankOccupant(players[0], rank: 0));
    expect(sut.rank(), HasRankOccupant(players[2], rank: 1));
    expect(sut.rank(), HasRankOccupant(players[3], rank: 2));
    expect(sut.rank(), HasRankOccupant(players[1], rank: 3));
  });

  test('two-way tie-break via direct win', () {
    RoundRobin<Team, List<MatchSet>, BadmintonMatch> tournament =
        createTournament(4);
    BadmintonRoundRobinRanking sut =
        tournament.finalRanking as BadmintonRoundRobinRanking;

    List<BadmintonMatch> matches = tournament.matches;

    // 0 and 1 both have 2 wins but 0 won the direct encounter
    // 0 wins vs 1
    arrangeScore(players[0], players[1], (21, 0), (21, 0), null, matches);
    // 0 wins vs 3
    arrangeScore(players[0], players[3], (21, 0), (21, 0), null, matches);
    // 1 wins vs 2
    arrangeScore(players[1], players[2], (21, 0), (21, 0), null, matches);
    // 1 wins vs 3
    arrangeScore(players[1], players[3], (21, 0), (21, 0), null, matches);
    // 2 wins vs 0
    arrangeScore(players[2], players[0], (21, 0), (21, 0), null, matches);
    // 3 wins vs 2
    arrangeScore(players[3], players[2], (21, 0), (21, 0), null, matches);

    expect(sut.rank(), hasLength(4));
    expect(sut.tiedRank(), hasLength(4));

    expect(sut.rank(), HasRankOccupant(players[0], rank: 0));
    expect(sut.rank(), HasRankOccupant(players[1], rank: 1));
  });

  test('two-way-tie', () {
    RoundRobin<Team, List<MatchSet>, BadmintonMatch> tournament =
        createTournament(2, 2);
    BadmintonRoundRobinRanking sut =
        tournament.finalRanking as BadmintonRoundRobinRanking;

    List<BadmintonMatch> matches = tournament.matches;

    // 0 wins vs 1
    arrangeScore(players[0], players[1], (21, 0), (21, 0), null, matches,
        matchIndex: 0);
    // 1 wins vs 0
    arrangeScore(players[1], players[0], (21, 0), (21, 0), null, matches,
        matchIndex: 1);

    expect(sut.rank(), hasLength(2));
    expect(sut.tiedRank(), hasLength(1));
  });

  test('two-way tie-break via direct sets', () {
    RoundRobin<Team, List<MatchSet>, BadmintonMatch> tournament =
        createTournament(2, 2);
    BadmintonRoundRobinRanking sut =
        tournament.finalRanking as BadmintonRoundRobinRanking;

    List<BadmintonMatch> matches = tournament.matches;

    // 0 wins vs 1
    arrangeScore(players[0], players[1], (21, 0), (21, 0), null, matches,
        matchIndex: 0);
    // 1 wins vs 0 in 3 sets
    arrangeScore(players[1], players[0], (21, 0), (0, 21), (21, 0), matches,
        matchIndex: 1);

    expect(sut.rank(), hasLength(2));
    expect(sut.tiedRank(), hasLength(2));

    expect(sut.rank(), HasRankOccupant(players[0], rank: 0));
    expect(sut.rank(), HasRankOccupant(players[1], rank: 1));
  });

  test('two-way tie-break via direct points', () {
    RoundRobin<Team, List<MatchSet>, BadmintonMatch> tournament =
        createTournament(2, 2);
    BadmintonRoundRobinRanking sut =
        tournament.finalRanking as BadmintonRoundRobinRanking;

    List<BadmintonMatch> matches = tournament.matches;

    // 0 wins vs 1 with points to 1
    arrangeScore(players[0], players[1], (21, 19), (21, 19), null, matches,
        matchIndex: 0);
    // 1 wins vs 0 without points to 0
    arrangeScore(players[1], players[0], (21, 0), (21, 0), null, matches,
        matchIndex: 1);

    expect(sut.rank(), hasLength(2));
    expect(sut.tiedRank(), hasLength(2));

    expect(sut.rank(), HasRankOccupant(players[1], rank: 0));
    expect(sut.rank(), HasRankOccupant(players[0], rank: 1));
  });

  test('two-way tie-break via overall sets', () {
    RoundRobin<Team, List<MatchSet>, BadmintonMatch> tournament =
        createTournament(3, 2);
    BadmintonRoundRobinRanking sut =
        tournament.finalRanking as BadmintonRoundRobinRanking;

    List<BadmintonMatch> matches = tournament.matches;

    // 0 wins vs 1
    arrangeScore(players[0], players[1], (21, 0), (21, 0), null, matches,
        matchIndex: 0);
    // 1 wins vs 0
    arrangeScore(players[1], players[0], (21, 0), (21, 0), null, matches,
        matchIndex: 1);

    // 0 wins vs 2 in 3 sets
    arrangeScore(players[0], players[2], (21, 0), (0, 21), (21, 0), matches,
        matchIndex: 0);
    arrangeScore(players[0], players[2], (21, 0), (0, 21), (21, 0), matches,
        matchIndex: 1);

    // 1 wins vs 2
    arrangeScore(players[1], players[2], (21, 0), (21, 0), null, matches,
        matchIndex: 0);
    arrangeScore(players[1], players[2], (21, 0), (21, 0), null, matches,
        matchIndex: 1);

    expect(sut.rank(), hasLength(3));
    expect(sut.tiedRank(), hasLength(3));

    expect(sut.rank(), HasRankOccupant(players[1], rank: 0));
    expect(sut.rank(), HasRankOccupant(players[0], rank: 1));
    expect(sut.rank(), HasRankOccupant(players[2], rank: 2));
  });

  test('two-way tie-break via overall points', () {
    RoundRobin<Team, List<MatchSet>, BadmintonMatch> tournament =
        createTournament(3, 2);
    BadmintonRoundRobinRanking sut =
        tournament.finalRanking as BadmintonRoundRobinRanking;

    List<BadmintonMatch> matches = tournament.matches;

    // 0 wins vs 1
    arrangeScore(players[0], players[1], (21, 0), (21, 0), null, matches,
        matchIndex: 0);
    // 1 wins vs 0
    arrangeScore(players[1], players[0], (21, 0), (21, 0), null, matches,
        matchIndex: 1);

    // 0 wins vs 2
    arrangeScore(players[0], players[2], (21, 0), (21, 0), null, matches,
        matchIndex: 0);
    arrangeScore(players[0], players[2], (21, 0), (21, 0), null, matches,
        matchIndex: 1);

    // 1 wins vs 2 with points to 2
    arrangeScore(players[1], players[2], (21, 5), (21, 7), null, matches,
        matchIndex: 0);
    arrangeScore(players[1], players[2], (21, 0), (21, 0), null, matches,
        matchIndex: 1);

    expect(sut.rank(), hasLength(3));
    expect(sut.tiedRank(), hasLength(3));

    expect(sut.rank(), HasRankOccupant(players[0], rank: 0));
    expect(sut.rank(), HasRankOccupant(players[1], rank: 1));
    expect(sut.rank(), HasRankOccupant(players[2], rank: 2));
  });
}
