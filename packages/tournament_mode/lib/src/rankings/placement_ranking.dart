import 'package:collection/collection.dart';
import 'package:tournament_mode/tournament_mode.dart';

/// Forwards the decorated target ranking's ranks via
/// [MatchParticipant.fromPlacement].
///
/// The difference to using the target ranking directly is that any call
/// to [MatchParticipant.resolvePlayer] re-evaluates the target-ranking.
class PlacementRanking<P> extends RankingDecorator<P> {
  PlacementRanking(super.targetRanking);

  @override
  List<MatchParticipant<P>> createRanks() {
    return targetRanking.ranks
        .mapIndexed(
          (index, _) => MatchParticipant.fromPlacement(
            Placement(ranking: targetRanking, place: index),
          ),
        )
        .toList();
  }

  @override
  void freezeRanks() {
    targetRanking.freezeRanks();
    super.freezeRanks();
  }
}
