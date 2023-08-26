import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/ranking.dart';

/// A match between two [MatchParticipant]s. The result of the match
/// is recorded in a score object of generic type [S]
abstract class TournamentMatch<P, S> {
  /// Creates a [TournamentMatch] between opponents [a] and [b].
  TournamentMatch(this.a, this.b);

  final MatchParticipant<P> a;
  final MatchParticipant<P> b;

  S? get score => _score;

  /// The score is set when the match result becomes known
  ///
  /// Setting the score also sets the [endTime] of the match.
  set score(S? score) {
    if (score == null) {
      endTime = null;
    } else {
      endTime = DateTime.now();
    }

    _score = score;
  }

  S? _score;

  DateTime? _startTime;

  /// The time when this match began.
  /// Usually set when players are called out.
  DateTime? get startTime => _startTime;

  /// The time this match ended.
  /// This is automatically set by the [score] setter.
  DateTime? endTime;

  /// Is `true` while this match is ongoing.
  bool get inProgress => _startTime != null && score == null;

  /// Is `true` when the match has a score recorded.
  bool get isCompleted => score != null;

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
  /// This is `true` when both participants are resolvable
  /// (read: both opponents are determined).
  bool isPlayable() {
    return a.readyToPlay() && b.readyToPlay();
  }

  /// Returns whether this match is a bye and thus only has one real
  /// participant.
  ///
  /// Byes should be specially treated in [Ranking]s.
  bool isBye() {
    return a.isBye || b.isBye;
  }

  /// Sets the start time of this match. If [startTime] is `null` it uses
  /// [DateTime.now].
  void beginMatch([DateTime? startTime]) {
    assert(isPlayable());
    DateTime time = startTime ?? DateTime.now();
    _startTime = time;
  }
}
