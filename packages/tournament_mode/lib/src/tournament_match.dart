import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/tournament_round.dart';

/// A match between two [MatchParticipant]s. The result of the match
/// is recorded in a score object of generic type [S]
abstract class TournamentMatch<P, S> {
  /// Creates a [TournamentMatch] between opponents [a] and [b].
  TournamentMatch(this.a, this.b);

  final MatchParticipant<P> a;
  final MatchParticipant<P> b;

  TournamentRound<TournamentMatch<P, S>>? round;

  S? get score => _score;

  S? _score;

  DateTime? _startTime;

  /// The time when this match began.
  /// Usually set when players are called out.
  DateTime? get startTime => _startTime;

  DateTime? _endTime;

  /// The time this match ended.
  /// This is automatically set by the [setScore] method.
  DateTime? get endTime => _endTime;

  /// Is `true` while this match is ongoing.
  bool get inProgress => _startTime != null && score == null;

  /// Is `true` when the match has a score recorded.
  bool get isCompleted => score != null;

  /// Is set when one of the opponents withdrew for some reason. The other
  /// opponent is the [walkoverWinner].
  MatchParticipant<P>? walkoverWinner;

  /// Returns the winner of the match, [a] or [b].
  ///
  /// Returns `null` if the [score] is `null`.
  MatchParticipant<P>? getWinner();

  /// Returns the loser by returning the opposite participant of [getWinner].
  ///
  /// If [getWinner] returns `null` it returns `null`.
  MatchParticipant<P>? getLoser() {
    MatchParticipant<P>? winner = getWinner();
    if (winner == null) {
      return null;
    }

    if (winner == a) {
      return b;
    } else {
      return a;
    }
  }

  /// Returns whether this match is playable according to the tournament's
  /// progress.
  ///
  /// This is `true` when both participants are [MatchParticipant.readyToPlay]
  bool get isPlayable => a.readyToPlay && b.readyToPlay;

  /// Returns whether this match is a bye and thus only has one real
  /// participant.
  ///
  /// Byes should be specially treated in [Ranking]s.
  bool get isBye => a.isBye || b.isBye;

  /// Sets the start time of this match. If [startTime] is `null` it uses
  /// [DateTime.now].
  void beginMatch([DateTime? startTime]) {
    assert(isPlayable);
    DateTime time = startTime ?? DateTime.now().toUtc();
    _startTime = time;
  }

  /// The score is set when the match result becomes known
  ///
  /// Setting the score also sets the [TournamentMatch.endTime] of the match to
  /// the current time or alternatively to the given [endTime].
  void setScore(S? score, {DateTime? endTime}) {
    if (score == null) {
      _endTime = null;
    } else {
      _endTime = endTime ?? DateTime.now().toUtc();
    }

    _score = score;
  }
}
