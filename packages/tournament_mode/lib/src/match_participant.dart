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
  MatchParticipant.fromPlayer(
    P player,
  )   : _player = player,
        placement = null,
        _isBye = false,
        _isDrawnBye = false;

  MatchParticipant._fromPlacement(
    this.placement,
  )   : _isBye = false,
        _isDrawnBye = false {
    placement!.ranking.addDependantParticipant(this);
  }

  /// Returns a [MatchParticipant] that is defined in terms of the [placement].
  ///
  /// If a MatchParticipant with an equal placement (same ranking and place)
  /// already exists, that existing instance is returned. Otherwise a new one
  /// is created.
  factory MatchParticipant.fromPlacement(Placement<P> placement) {
    MatchParticipant<P>? existing =
        placement.ranking.getExistingDependant(placement);

    MatchParticipant<P> placementParticipant =
        existing ?? MatchParticipant._fromPlacement(placement);

    return placementParticipant;
  }

  /// Creates a [MatchParticipant] as a stand in for a bye. The opponent of this
  /// participant either has a break due to an uneven number of entries or
  /// gets to advance to the next round due to seeding or a lucky draw.
  MatchParticipant.bye({
    bool isDrawnBye = true,
  })  : placement = null,
        _isBye = true,
        _isDrawnBye = isDrawnBye;

  P? _player;

  P? get player => _player;
  final Placement<P>? placement;

  /// Whether this participant is a bye for the opponent.
  ///
  /// A bye participant can be directly created with the [MatchParticipant.bye]
  /// constructor.
  /// Participants from the [MatchParticipant.fromPlacement] constructor can
  /// also become byes when the placement itself is a bye.
  bool get isBye {
    if (_isBye) {
      return true;
    }

    MatchParticipant<P>? place = placement?.getPlacement();

    if (place != null) {
      return place.isBye;
    }

    return false;
  }

  final bool _isBye;

  final bool _isDrawnBye;

  /// Whether this participant is a bye because it was directly constructed
  /// with [MatchParticipant.bye].
  bool get isDrawnBye => _isDrawnBye;

  /// Returns whether this participant is ready to start a match.
  bool get readyToPlay => !_isBye && player != null;

  /// Updates the player who is filling this participant's role.
  ///
  /// This has to be called after the [placement]'s ranking updated.
  ///
  /// Does nothing if this is not a [MatchParticipant.fromPlacement].
  void updatePlayer() {
    if (placement == null || _isBye) {
      return;
    }

    _player = placement!.getPlacement()?.player;
  }
}
