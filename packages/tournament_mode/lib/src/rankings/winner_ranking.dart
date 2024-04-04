import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/tournament_match.dart';

/// Ranks the participants of a match by who won.
class WinnerRanking<P, S> extends Ranking<P> {
  /// Creates a [WinnerRanking] from the given [match]
  WinnerRanking(this.match) {
    assert(
      match.winnerRanking == null,
      "Do not create multiple WinnerRankings for one match",
    );
    match.winnerRanking = this;
  }

  final TournamentMatch<P, S> match;

  @override
  List<MatchParticipant<P>> createRanks() {
    switch (match) {
      case TournamentMatch(
          hasWinner: true,
        ):
        MatchParticipant<P>? loser = match.getLoser();
        if (loser != null && loser.isDrawnBye) {
          // Convert a drawn bye to a normal bye
          loser = MatchParticipant.bye(isDrawnBye: false);
        }
        return [
          match.getWinner()!,
          if (loser != null) loser,
        ];

      default:
        return [];
    }
  }
}

/// A [Placement] for a [WinnerRanking].
///
/// It replaces any placed participants that withdrew from the match with
/// a [MatchParticipant.bye]. This way no withdrawn players can pass this
/// placement.
class WinnerPlacement<P> extends Placement<P> {
  WinnerPlacement({
    required WinnerRanking<P, dynamic> ranking,
    required super.place,
  }) : super(ranking: ranking);

  @override
  WinnerRanking<P, dynamic> get ranking =>
      super.ranking as WinnerRanking<P, dynamic>;

  @override
  MatchParticipant<P>? getPlacement() {
    MatchParticipant<P>? placement = super.getPlacement();

    if (placement == null) {
      return null;
    }

    List<P> withdrawnPlayers = (ranking.match.withdrawnParticipants ?? [])
        .map((participant) => participant.player)
        .whereType<P>()
        .toList();

    P? player = placement.player;

    if (withdrawnPlayers.contains(player)) {
      return MatchParticipant<P>.bye();
    }

    return placement;
  }
}
