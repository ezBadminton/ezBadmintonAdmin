import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/ranking.dart';

/// The simplest possible seeding of just an ordered list of players.
class DrawSeeds<P> extends Ranking<P> {
  /// Creates [DrawSeeds] of the [seededPlayers] with the order of the list
  /// determining the seeds.
  ///
  /// Each [P] is wrapped with a [MatchParticipant.fromPlayer].
  DrawSeeds(List<P> seededPlayers)
      : _seededParticipants = seededPlayers.map(_wrapPlayer).toList();

  /// Creates [DrawSeeds] of the [seededParticipants] with the order of the list
  /// determining the seeds.
  DrawSeeds.fromParticipants(List<MatchParticipant<P>> seededParticipants)
      : _seededParticipants = seededParticipants;

  final List<MatchParticipant<P>> _seededParticipants;

  @override
  List<MatchParticipant<P>> createRanks() => _seededParticipants;

  static MatchParticipant<P> _wrapPlayer<P>(P player) =>
      MatchParticipant.fromPlayer(player);
}
