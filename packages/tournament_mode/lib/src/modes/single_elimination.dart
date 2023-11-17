import 'dart:math';

import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/rankings/elimination_ranking.dart';
import 'package:tournament_mode/src/rankings/match_ranking.dart';
import 'package:tournament_mode/src/rankings/winner_ranking.dart';
import 'package:tournament_mode/src/round_types/elimination_round.dart';
import 'package:tournament_mode/src/tournament_match.dart';
import 'package:tournament_mode/src/tournament_mode.dart';

/// Single elimination mode. All players are entered into a tournament
/// tree where each winner progresses to the next round until the finals.
class SingleElimination<P, S, M extends TournamentMatch<P, S>>
    extends TournamentMode<P, S, M> {
  /// Creates a [SingleElimination] tournament with the given [seededEntries].
  ///
  /// If no seeding is needed a random ranking can be used aswell.
  ///
  /// If the amount of players is not a power of 2, the first seeds get a bye
  /// in the first round.
  ///
  /// The rounded up binary logarithm of the amount of seeded players
  /// (length of [Ranking.rank]) determines the number of rounds. In other words
  /// a minimum complete tournament tree is always constructed.
  SingleElimination({
    required Ranking<P> seededEntries,
    required this.matcher,
  })  : entries = _BinaryRanking(seededEntries),
        finalRanking = EliminationRanking() {
    _createMatches();
    finalRanking.initRounds(roundMatches.toList());
  }

  @override
  final Ranking<P> entries;

  /// A function turning two participants into a specific [TournamentMatch].
  final M Function(
    MatchParticipant<P> a,
    MatchParticipant<P> b,
  ) matcher;

  late final List<MatchParticipant<P>> _participants;

  @override
  List<M> get matches =>
      [for (EliminationRound<M> round in rounds) ...round.matches];

  late List<EliminationRound<M>> _rounds;
  @override
  List<EliminationRound<M>> get rounds => _rounds;

  @override
  final MatchRanking<P, S, M> finalRanking;

  void _createMatches() {
    _participants = entries.rank();

    assert(_participants.length > 1);

    int rounds = _getNumRounds(_participants.length);

    List<List<M>> eliminationMatches = [];
    List<MatchParticipant<P>> roundParticipants = _participants;
    for (int round = 0; round < rounds; round += 1) {
      List<M> roundMatches;
      if (round == 0) {
        roundMatches = _createSeededEliminationRound(roundParticipants);
      } else {
        roundMatches = _createEliminationRound(roundParticipants);
      }

      roundParticipants = _createNextRoundParticipants(roundMatches);

      eliminationMatches.add(roundMatches);
    }

    _rounds = List.generate(
      eliminationMatches.length,
      (index) => EliminationRound(
        matches: eliminationMatches[index],
        tournament: this,
        roundSize: pow(2, eliminationMatches.length - index) as int,
      )..initMatches(),
    );
  }

  /// Takes a list of [roundParticipants] and matches them pair-wise in the
  /// list's order (1st vs 2nd, 3rd vs 4th, ...).
  List<M> _createEliminationRound(
    List<MatchParticipant<P>> roundParticipants,
  ) {
    List<M> roundMatches = [];
    for (int i = 0; i < roundParticipants.length; i += 2) {
      MatchParticipant<P> a = roundParticipants[i];
      MatchParticipant<P> b = roundParticipants[i + 1];
      roundMatches.add(matcher(a, b));
    }

    return roundMatches;
  }

  /// Takes a seeded list of [roundParticipants] and matches them according
  /// to their seeds.
  /// More info: https://en.wikipedia.org/wiki/Single-elimination_tournament#Seeding
  ///
  /// Example with 8 participants:
  ///  * 1st vs 8th
  ///  * 4th vs 5th
  ///  * 2nd vs 7th
  ///  * 3rd vs 6th
  ///
  /// 1st and 2nd seed are in opposite branches of the tournament tree.
  /// Opponents are matched by mirrored seed.
  List<M> _createSeededEliminationRound(
    List<MatchParticipant<P>> roundParticipants,
  ) {
    int rounds = _getNumRounds(roundParticipants.length);
    List<(int, int)> seedMatchups = _createSeedMatchups(rounds);

    List<M> roundMatches = seedMatchups
        .map(
          (matchup) => matcher(
            roundParticipants[matchup.$1],
            roundParticipants[matchup.$2],
          ),
        )
        .toList();

    return roundMatches;
  }

  /// Creates a list of integer tuples that represent matchups between seeds.
  /// The matchups are ordered such that the top 2 seeds' paths in the
  /// tournament tree meet at the final, the top 4 meet at the semi-finals,
  /// etc...
  ///
  /// The given [rounds] dictate how many rounds the returned matchups will
  /// produce when played out until the final.
  static List<(int, int)> _createSeedMatchups(int rounds) {
    // The root node (the final) where the paths of seed 0 and 1 meet.
    List<(int, int)> seedMatchups = [(0, 1)];

    for (int r = 1; r < rounds; r += 1) {
      // Determine the matchups of the next 2^r seeds

      List<(int, int)> nextSeedMatchups = [];
      int totalSeeds = pow(2, r + 1) as int;
      for ((int, int) parentMatchup in seedMatchups) {
        int opponent1 = parentMatchup.$1;
        int opponent2 = parentMatchup.$2;

        nextSeedMatchups.add((opponent1, totalSeeds - 1 - opponent1));
        nextSeedMatchups.add((opponent2, totalSeeds - 1 - opponent2));
      }
      // Go up the tournament tree
      seedMatchups = nextSeedMatchups;
    }

    return seedMatchups;
  }

  /// Creates the match list of the round coming
  /// after the given [roundMatches].
  List<MatchParticipant<P>> _createNextRoundParticipants(
    List<TournamentMatch<P, S>> roundMatches,
  ) {
    // The winners are determined by placement in a WinnerRanking
    List<MatchParticipant<P>> winners = roundMatches.map(
      (match) {
        WinnerRanking<P, S> winnerRanking = WinnerRanking(match);
        return MatchParticipant.fromPlacement(
          Placement(ranking: winnerRanking, place: 0),
        );
      },
    ).toList();

    return winners;
  }

  /// [numParticipants] has to be a power of two
  int _getNumRounds(int numParticipants) {
    int rounds = 0;
    while (numParticipants > 1) {
      numParticipants >>= 1;
      rounds += 1;
    }

    return rounds;
  }

  @override
  List<M> withdrawPlayer(P player) {
    List<M> incompleteMatchesOfPlayer = matches
        .where(
          (m) => m.a.resolvePlayer() == player || m.b.resolvePlayer() == player,
        )
        .where((m) => !m.isCompleted)
        .toList();

    return incompleteMatchesOfPlayer;
  }
}

/// A ranking with a number of ranks that is a power of two.
class _BinaryRanking<P> implements Ranking<P> {
  /// Decorates the given [targetRanking] by padding the rank list with
  /// [MatchParticipant.bye] until the number of ranks reaches a power of two.
  ///
  /// Does nothing if the [targetRanking]'s number of ranks already is a power
  /// of two.
  _BinaryRanking(this.targetRanking);

  final Ranking<P> targetRanking;

  @override
  List<MatchParticipant<P>> rank() {
    List<MatchParticipant<P>> targetRanks = targetRanking.rank();
    int numRanks = targetRanks.length;

    int padding = _nextPowerOfTwo(numRanks) - numRanks;

    return [
      ...targetRanks,
      ...List.generate(padding, (_) => const MatchParticipant.bye()),
    ];
  }

  /// Returns the power of two that is immediately bigger than or equal to
  /// [from].
  int _nextPowerOfTwo(int from) {
    int nextPowerOfTwo = 1;
    while (nextPowerOfTwo < from) {
      nextPowerOfTwo *= 2;
    }

    return nextPowerOfTwo;
  }
}
