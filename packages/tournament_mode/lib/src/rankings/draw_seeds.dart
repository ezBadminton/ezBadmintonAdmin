import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/ranking.dart';

/// The simplest possible seeding of just an ordered list of players.
class DrawSeeds<P> implements Ranking<P> {
  /// Creates [DrawSeeds] of the [seededPlayers] with the order of the list
  /// determining the seeds.
  DrawSeeds(this.seededPlayers)
      : _seededParticipants = seededPlayers.map(_wrapPlayer).toList();

  final List<P> seededPlayers;

  final List<MatchParticipant<P>> _seededParticipants;

  @override
  List<MatchParticipant<P>> rank() => _seededParticipants;

  static MatchParticipant<P> _wrapPlayer<P>(P player) =>
      MatchParticipant.fromPlayer(player);
}
