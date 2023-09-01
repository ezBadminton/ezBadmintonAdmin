import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/tournament_match.dart';

/// One participant of a [TournamentMatch]. A [MatchParticipant] represents
/// either a player [P] directly or a [Placement].
/// A [Placement] represents a participant who placed a certain place in a
/// [Ranking].
///
/// Thus a match's participants can be determined by the results of other
/// matches.
///
/// Example:
///
/// This way the participants of a final can be defined in terms of the winners
/// of the semi-finals. Those in turn are defined by the quarter-finals and
/// those could be defined by the rankings of a group stage. Even further, the
/// group splits can be defined by a seeded ranking. The root participants
/// (where [P] is directly defined) are the input to the seeded ranking.
class MatchParticipant<P> {
  /// Creates a [MatchParticipant] that is directly defined by [player]
  const MatchParticipant.fromPlayer(
    this.player,
  )   : placement = null,
        isBye = false;

  /// Creates a [MatchParticipant] that is defined in terms of the [placement].
  const MatchParticipant.fromPlacement(
    this.placement,
  )   : player = null,
        isBye = false;

  /// Creates a [MatchParticipant] as a stand in for a bye. The opponent of this
  /// participant either has a break due to an uneven number of entries or
  /// gets to advance to the next round due to seeding or a lucky draw.
  const MatchParticipant.bye()
      : player = null,
        placement = null,
        isBye = true;

  final P? player;
  final Placement<P>? placement;

  final bool isBye;

  /// Resolves to a player [P] who is actually going to fill this participant's
  /// role.
  ///
  /// If the participant is defined by a [placement] and the necessary results
  /// to determine it are not yet known, it returns `null`.
  P? resolvePlayer() {
    if (isBye) {
      return null;
    }

    if (player != null) {
      return player;
    }

    return placement!.getPlacement()?.resolvePlayer();
  }

  /// Returns whether this participant is ready to start a match.
  bool readyToPlay() {
    if (isBye) {
      return true;
    }

    return resolvePlayer() != null;
  }
}
