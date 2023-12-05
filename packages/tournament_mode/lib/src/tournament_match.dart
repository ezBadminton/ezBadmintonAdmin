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
  bool get inProgress => _startTime != null && _endTime == null;

  /// Is `true` when the match has a winner.
  bool get hasWinner => getWinner() != null;

  /// This list is filled when one or both of the participants withdrew
  /// for some reason.
  List<MatchParticipant<P>>? withdrawnParticipants;

  /// This is set when the match is decided due to [withdrawnParticipants].
  ///
  /// When only one participant withdrew, the other one becomes the
  /// [walkoverWinner].
  ///
  /// When both withdrew a [MatchParticipant.bye] is returned as the winner.
  /// This causes the next round that the winner might be qualified for to
  /// become a bye round for the other qualified opponent.
  MatchParticipant<P>? get walkoverWinner {
    if (!isWalkover) {
      return null;
    }

    if (withdrawnParticipants!.length == 1) {
      if (withdrawnParticipants!.first == a) {
        return b;
      } else if (withdrawnParticipants!.first == b) {
        return a;
      }
    }

    return const MatchParticipant.bye(isDrawnBye: false);
  }

  /// This is set only when the match is decided due to being a bye.
  MatchParticipant<P>? get byeWinner {
    if (!isBye) {
      return null;
    }

    return a.isBye ? b : a;
  }

  /// Returns the winner of the match, [a] or [b].
  ///
  /// Returns `null` if the [score] is `null`.
  MatchParticipant<P>? getWinner();

  /// Returns the loser by returning the opposite participant of [getWinner].
  ///
  /// If [getWinner] returns null it returns null.
  /// If the winner is a [MatchParticipant.bye] it also returns null.
  MatchParticipant<P>? getLoser() {
    MatchParticipant<P>? winner = getWinner();

    if (winner == a) {
      return b;
    } else if (winner == b) {
      return a;
    }

    return null;
  }

  /// Returns whether this match is playable according to the tournament's
  /// progress.
  ///
  /// This is `true` when both participants are [MatchParticipant.readyToPlay].
  bool get isPlayable => a.readyToPlay && b.readyToPlay;

  /// Returns whether this match is a bye and thus only has one real
  /// participant.
  ///
  /// Byes should be specially treated in [Ranking]s.
  bool get isBye => a.isBye || b.isBye;

  /// Returns whether this match is a bye by draw.
  ///
  /// A bye by draw stems from an uneven amount of participants.
  /// A bye "not by draw" is a bye that is granted when nobody qualifies
  /// for a round because both participants of the previous round gave a
  /// walkover.
  bool get isDrawnBye => a.isDrawnBye || b.isDrawnBye;

  /// Returns whether this match is a walkover.
  ///
  /// That is the case when one or both match participants withdrew.
  bool get isWalkover => withdrawnParticipants?.isNotEmpty ?? false;

  /// Sets the start time of this match. If [startTime] is `null` it uses
  /// [DateTime.now].
  void beginMatch([DateTime? startTime]) {
    assert(isPlayable);
    DateTime time = startTime ?? DateTime.now().toUtc();
    _startTime = time;
  }

  /// This is called when the match ended but the score is not known.
  ///
  /// It sets the [TournamentMatch.endTime] to the current time.
  ///
  /// [setScore] should be called at a later time when the score becomes known.
  ///
  /// If [endTime] is `null` it uses [DateTime.now].
  void endMatch([DateTime? endTime]) {
    DateTime time = endTime ?? DateTime.now().toUtc();
    _endTime = time;
  }

  /// Sets the [score].
  ///
  /// When the [TournamentMatch.endTime] is null, setting the score also sets
  /// the [TournamentMatch.endTime] to the current time or alternatively to the
  /// given [endTime].
  void setScore(S score, {DateTime? endTime}) {
    _endTime ??= endTime ?? DateTime.now().toUtc();

    _score = score;
  }
}
