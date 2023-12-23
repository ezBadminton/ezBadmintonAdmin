import 'package:tournament_mode/src/rankings/ordered_ranking.dart';
import 'package:tournament_mode/src/rankings/placement_ranking.dart';
import 'package:tournament_mode/tournament_mode.dart';

class ConsolationRanking<P> extends Ranking<P> {
  ConsolationRanking(
    List<MatchParticipant<P>> losers,
  ) : loserRanking = OrderedRanking(losers) {
    loserPlacements = PlacementRanking(loserRanking);
  }

  final OrderedRanking<P> loserRanking;
  late final PlacementRanking<P> loserPlacements;

  @override
  List<MatchParticipant<P>> createRanks() => loserPlacements.createRanks();
}
