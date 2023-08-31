import 'package:collection/collection.dart';
import 'package:tournament_mode/src/round_types/elimination_round.dart';
import 'package:tournament_mode/src/round_types/round_robin_round.dart';
import 'package:tournament_mode/src/tournament_match.dart';
import 'package:tournament_mode/src/tournament_mode.dart';

/// One round of a tournament mode. A round is a list of matches that can
/// be played in parallel, given the round before it has finished.
///
/// This class is just a [DelegatingList] for [TournamentMatch]es. It can be
/// subclassed to add more info to the [TournamentMode.rounds] list.
///
/// See:
/// * [RoundRobinRound] is a [TournamentRound] with round numbering information.
/// * [EliminationRound] is used to represent one round in an elemination
/// tournament tree.
class TournamentRound<P, S> extends DelegatingList<TournamentMatch<P, S>> {
  /// Creates a [TournamentRound] containing the [roundMatches].
  TournamentRound({
    required List<TournamentMatch<P, S>> roundMatches,
    this.nestedRounds = const [],
  }) : super(roundMatches);

  /// Other rounds that this round is composed of
  /// (e.g. a round of a group phase stems from multiple round robin rounds)
  ///
  /// Is empty when no underlying rounds exist
  final List<TournamentRound<P, S>> nestedRounds;
}
