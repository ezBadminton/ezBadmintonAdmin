import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/rankings/rankings.dart';
import 'package:tournament_mode/src/tournament_mode.dart';

class PassthroughRanking<P> extends RankingDecorator<P> {
  /// Create a [PassthroughRanking] for the given [targetRanking].
  ///
  /// It passes the [targetRanking]'s ranks through [PassthroughPlacement]s to
  /// the [ranks] of this ranking.
  ///
  /// This allows the [targetRanking] to change it's ranks while a
  /// [TournamentMode] can use this [PassthroughRanking] as its entry list
  /// since the ranks of it stay tied to the same placements.
  ///
  /// Optionally a [passthroughCondition] can be given. The
  /// [PassthroughPlacement]s will not let the participants pass while the
  /// condition resolves to false even if the [targetRanking] has an occupant
  /// on the placement. When no [passthroughCondition] is given, the
  /// [PassthroughPlacement]s behave like basic [Placement]s.
  PassthroughRanking(
    super.targetRanking, {
    this.passthroughCondition,
  });

  bool Function(MatchParticipant<P>? participant)? passthroughCondition;

  @override
  List<MatchParticipant<P>> createRanks() {
    return [
      for (int i = 0; i < targetRanking.ranks.length; i += 1)
        MatchParticipant.fromPlacement(
          PassthroughPlacement(
            ranking: targetRanking,
            place: i,
            passthroughCondition: passthroughCondition,
          ),
        )
    ];
  }
}

class PassthroughPlacement<P> extends Placement<P> {
  PassthroughPlacement({
    required super.ranking,
    required super.place,
    required this.passthroughCondition,
  });

  bool Function(MatchParticipant<P>? participant)? passthroughCondition;

  @override
  MatchParticipant<P>? getPlacement() {
    MatchParticipant<P>? placement = super.getPlacement();

    bool condition = passthroughCondition?.call(placement) ?? true;
    if (!condition) {
      return null;
    }

    return placement;
  }

  /// Returns the placement while ignoring the [passthroughCondition]
  MatchParticipant<P>? getUnblockedPlacement() {
    return super.getPlacement();
  }
}
