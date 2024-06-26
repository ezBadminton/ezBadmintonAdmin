import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/rankings/rankings.dart';
import 'package:tournament_mode/src/tournament_round.dart';

/// A match between two [MatchParticipant]s. The result of the match
/// is recorded in a score object of generic type [S]
abstract class TournamentMatch<P, S> {
  /// Creates a [TournamentMatch] between opponents [a] and [b].
  TournamentMatch(this.a, this.b) {
    _fingerprint = _getFingerprint();
  }

  final MatchParticipant<P> a;
  final MatchParticipant<P> b;

  TournamentRound<TournamentMatch<P, S>>? round;

  /// The next matches in the qualification chain of this match.
  ///
  /// This should be set by the tournament mode creating this match.
  ///
  /// It might be an empty list when the match is part of a tournament that has
  /// no qualification chain (e.g. round robin) or on a final match.
  ///
  /// When the list contains 2 matches, the first one is the match
  /// that the winner qualifies for and the second is the one that the loser
  /// qualifies for.
  /// If it is only one match then the loser of the match is out.
  List<TournamentMatch<P, S>> nextMatches = [];

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

  /// This becomes set when the match is used to create a [WinnerRanking]
  WinnerRanking<P, S>? winnerRanking;

  List<P>? withdrawnPlayers;

  /// This list is filled when one or both of the participants withdrew
  /// for some reason.
  List<MatchParticipant<P>>? get withdrawnParticipants {
    if (withdrawnPlayers == null || withdrawnPlayers!.isEmpty) {
      return null;
    }

    List<MatchParticipant<P>> withdrawnParticipants = [a, b]
        .where(
          (participant) => withdrawnPlayers!.contains(participant.player),
        )
        .toList();

    return withdrawnParticipants;
  }

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

    return MatchParticipant.bye(isDrawnBye: false);
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

  /// Reset the match to prepare it for hydration
  void resetMatch() {
    _startTime = null;
    _endTime = null;
    _score = null;
    withdrawnPlayers = null;
  }

  String getPlayerFingerprint(P? player);
  String getScoreFingerprint(S? score);

  bool _isDirty = false;
  bool get isDirty => _isDirty;

  void setClean() {
    _isDirty = false;
  }

  String _fingerprint = "";
  String get fingerprint => _fingerprint;

  void updateFingerprint() {
    String newFingerprint = _getFingerprint();
    _isDirty = fingerprint != newFingerprint;
    _fingerprint = newFingerprint;
  }

  /// Returns a fingerprint that identifies equal match objects.
  ///
  /// The fingerprint is constructed from the participant's players, the score
  /// and the withdrawn participant's players.
  String _getFingerprint() {
    StringBuffer fingerprintBuilder = StringBuffer(
      '${getPlayerFingerprint(a.player)}:${getPlayerFingerprint(b.player)}:${getScoreFingerprint(score)}',
    );

    if (withdrawnParticipants != null) {
      for (MatchParticipant<P> participant in withdrawnParticipants!) {
        fingerprintBuilder.write(getPlayerFingerprint(participant.player));
      }
    }

    return fingerprintBuilder.toString();
  }
}
