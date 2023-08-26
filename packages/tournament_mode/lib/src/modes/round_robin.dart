import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/rankings/match_ranking.dart';
import 'package:tournament_mode/src/tournament_match.dart';
import 'package:tournament_mode/src/tournament_mode.dart';

/// Arguably the simplest tournament mode. Every player plays everyone else.
class RoundRobin<P, S> extends TournamentMode<P, S> {
  /// Creates a [RoundRobin] tournament.
  RoundRobin({
    required this.players,
    required this.ranking,
    required this.matcher,
    this.passes = 1,
  }) : assert(players.length >= 2) {
    _createMatches();
    ranking.initMatches(matches);
  }

  /// The competing players.
  final List<P> players;

  /// The ranking to use. When all matches have been played the
  /// [MatchRanking.rank] method should return the ranked player list.
  final MatchRanking<P, S> ranking;

  /// A function turning two participants into a specific [TournamentMatch].
  final TournamentMatch<P, S> Function(
    MatchParticipant<P> a,
    MatchParticipant<P> b,
  ) matcher;

  /// The amount of round robin passes to play
  /// (for example set this to `2` to get a "double round robin").
  final int passes;

  late final List<MatchParticipant<P>> participants;

  @override
  List<TournamentMatch<P, S>> get matches =>
      [for (List<TournamentMatch<P, S>> round in rounds) ...round];

  late List<List<TournamentMatch<P, S>>> _rounds;
  @override
  List<List<TournamentMatch<P, S>>> get rounds => _rounds;

  /// This method uses
  /// https://en.wikipedia.org/wiki/Round-robin_tournament#Circle_method
  /// to create the matches
  void _createMatches() {
    participants = [
      for (P player in players) MatchParticipant.fromPlayer(player),
    ];
    if (!players.length.isEven) {
      participants.insert(1, const MatchParticipant.bye());
    }

    int roundsPerPass = participants.length - 1;
    int matchesPerRound = participants.length ~/ 2;

    List<MatchParticipant<P>> matchingCircle = List.of(participants);

    List<List<TournamentMatch<P, S>>> roundRobinMatches = [];
    for (int pass = 0; pass < passes; pass += 1) {
      for (int roundNum = 0; roundNum < roundsPerPass; roundNum += 1) {
        roundRobinMatches.add([]);
        for (int matchNum = 0; matchNum < matchesPerRound; matchNum += 1) {
          TournamentMatch<P, S> match = _matchParticipants(
            pass,
            roundNum,
            matchNum,
            matchingCircle[matchNum],
            matchingCircle[participants.length - 1 - matchNum],
          );

          int totalRoundNum = (pass * roundsPerPass) + roundNum;
          roundRobinMatches[totalRoundNum].add(match);
        }
        _rotateMatchingCircle(matchingCircle);
      }
    }

    _rounds = List.unmodifiable(roundRobinMatches);
  }

  void _rotateMatchingCircle(
    List<MatchParticipant<P>> matchingCircle,
  ) {
    MatchParticipant<P> rotated = matchingCircle.removeLast();
    matchingCircle.insert(1, rotated);
  }

  /// Creates a match with alternating matchup orientations between passes.
  ///
  /// This makes it so that each participant gets the same amount of
  /// first named matchups. If [passes] is not even, some participants will
  /// unavoidably have one more or one less first named match.
  TournamentMatch<P, S> _matchParticipants(
    int pass,
    int round,
    int match,
    MatchParticipant<P> a,
    MatchParticipant<P> b,
  ) {
    MatchParticipant<P> first = a;
    MatchParticipant<P> second = b;

    if (match == 0 && round.isEven) {
      first = b;
      second = a;
    }

    if (pass.isEven) {
      MatchParticipant<P> temp = first;
      first = second;
      second = temp;
    }

    return matcher(first, second);
  }
}
