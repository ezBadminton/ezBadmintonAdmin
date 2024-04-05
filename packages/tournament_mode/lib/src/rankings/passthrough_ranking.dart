import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/rankings/rankings.dart';
import 'package:tournament_mode/src/tournament_mode.dart';

class PassthroughRanking<P> extends RankingDecorator<P> {
  /// Create a [PassthroughRanking] for the given [targetRanking].
  ///
  /// It passes the [targetRanking]'s ranks through [Placement]s to the [ranks]
  /// of this ranking.
  ///
  /// This allows the [targetRanking] to change it's ranks while a
  /// [TournamentMode] can use this [PassthroughRanking] as its entry list
  /// since the ranks of it stay tied to the same placements.
  PassthroughRanking(super.targetRanking);

  @override
  List<MatchParticipant<P>> createRanks() {
    return [
      for (int i = 0; i < targetRanking.ranks.length; i += 1)
        MatchParticipant.fromPlacement(
          Placement(ranking: targetRanking, place: i),
        )
    ];
  }
}
