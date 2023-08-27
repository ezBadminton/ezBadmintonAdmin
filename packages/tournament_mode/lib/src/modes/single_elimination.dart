import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/rankings/draw_seeds.dart';
import 'package:tournament_mode/src/rankings/winner_ranking.dart';
import 'package:tournament_mode/src/tournament_match.dart';
import 'package:tournament_mode/src/tournament_mode.dart';

/// Single elimination mode. All players are entered into a tournament
/// tree where each winner progresses to the next round until the finals.
class SingleElimination<P, S> extends TournamentMode<P, S> {
  /// Creates a [SingleElimination] tournament with the given [seeds].
  ///
  /// The rounded up binary logarithm of the amount of seeded players
  /// (length of [Ranking.rank]) determines the number of rounds. In other words
  /// a minimum complete tournament tree is always constructed.
  SingleElimination({
    required Ranking<P> seeds,
    required this.matcher,
  }) : seeds = _BinaryRanking(seeds) {
    _createMatches();
  }

  /// The players are entered in a seeded Ranking (e.g. [DrawSeeds])
  ///
  /// If no seeding is needed a random ranking can be used aswell.
  ///
  /// If the amount of players is not a power of 2, the first seeds get a bye
  /// in the first round.
  final Ranking<P> seeds;

  /// A function turning two participants into a specific [TournamentMatch].
  final TournamentMatch<P, S> Function(
    MatchParticipant<P> a,
    MatchParticipant<P> b,
  ) matcher;

  late final List<MatchParticipant<P>> participants;

  @override
  List<TournamentMatch<P, S>> get matches =>
      [for (List<TournamentMatch<P, S>> round in rounds) ...round];

  late List<List<TournamentMatch<P, S>>> _rounds;
  @override
  List<List<TournamentMatch<P, S>>> get rounds => _rounds;

  void _createMatches() {
    participants = seeds.rank().whereType<MatchParticipant<P>>().toList();

    assert(participants.length > 1);

    int rounds = _getNumRounds(participants.length);

    List<List<TournamentMatch<P, S>>> eliminationMatches = [];
    List<MatchParticipant<P>> roundParticipants = participants;
    for (int round = 0; round < rounds; round += 1) {
      List<TournamentMatch<P, S>> roundMatches;
      if (round == 0) {
        roundMatches = _createSeededEliminationRound(roundParticipants);
      } else {
        roundMatches = _createEliminationRound(roundParticipants);
      }

      roundParticipants = _createNextRoundParticipants(roundMatches);

      eliminationMatches.add(roundMatches);
    }

    _rounds = List.unmodifiable(eliminationMatches);
  }

  /// Takes a seeded list of [roundParticipants] and matches them by
  /// mirroring their ranks. Also the order of the returned match list separates
  /// the top players from each other so they can't meet before the final.
  ///
  /// Example with 8 participants:
  ///  * 1st vs 8th
  ///  * 3rd vs 6th
  ///  * 4th vs 5th
  ///  * 2nd vs 7th
  ///
  /// 1st and 2nd seed are in opposite ends of the match list. Opponents are
  /// matched by mirrored seed.
  List<TournamentMatch<P, S>> _createSeededEliminationRound(
    List<MatchParticipant<P>> roundParticipants,
  ) {
    List<TournamentMatch<P, S>> roundMatches = [];
    for (int i = 0; i < roundParticipants.length ~/ 2; i += 1) {
      MatchParticipant<P> a = roundParticipants[i];
      MatchParticipant<P> b =
          roundParticipants[roundParticipants.length - 1 - i];
      if (i.isEven) {
        roundMatches.insert(i ~/ 2, matcher(a, b));
      } else {
        roundMatches.insert(i ~/ 2 + 1, matcher(a, b));
      }
    }

    return roundMatches;
  }

  /// Takes a list of [roundParticipants] and matches them pair-wise in the
  /// list's order (1st vs 2nd, 3rd vs 4th, ...).
  List<TournamentMatch<P, S>> _createEliminationRound(
    List<MatchParticipant<P>> roundParticipants,
  ) {
    List<TournamentMatch<P, S>> roundMatches = [];
    for (int i = 0; i < roundParticipants.length; i += 2) {
      MatchParticipant<P> a = roundParticipants[i];
      MatchParticipant<P> b = roundParticipants[i + 1];
      roundMatches.add(matcher(a, b));
    }

    return roundMatches;
  }

  /// Creates the participant list of the round coming
  /// after the given [roundMatches].
  List<MatchParticipant<P>> _createNextRoundParticipants(
    List<TournamentMatch<P, S>> roundMatches,
  ) {
    // The winners are determined by placement in a WinnerRanking
    List<MatchParticipant<P>> winners = roundMatches
        .map(
          (match) => MatchParticipant.fromPlacement(
            Placement(ranking: WinnerRanking<P, S>(match), place: 0),
          ),
        )
        .toList();

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
}

///A ranking with a number of ranks that is a power of two.
class _BinaryRanking<P> implements Ranking<P> {
  /// Decorates the given [targetRanking] by padding the rank list with
  /// [MatchParticipant.bye] until the number of ranks reaches a power of two.
  ///
  /// Does nothing if the [targetRanking]'s number of ranks already is a power
  /// of two.
  _BinaryRanking(this.targetRanking);

  final Ranking<P> targetRanking;

  @override
  List<MatchParticipant<P>?> rank() {
    List<MatchParticipant<P>?> targetRanks = targetRanking.rank();
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
