import 'package:collection/collection.dart';
import 'package:tournament_mode/src/match_participant.dart';

/// A class that ranks [MatchParticipant]s. It's not necessarily a ranking by
/// match results but can also be the result of a random or seeded draw.
abstract class Ranking<P> {
  /// Returns a list of [MatchParticipant]s ordered by rank
  List<MatchParticipant<P>?> rank();
}

/// A [Ranking] that possibly has multiple participants on a single rank (ties).
mixin TieableRanking<P> implements Ranking<P> {
  @override
  List<MatchParticipant<P>?> rank() {
    return tiedRank().expand((tie) => tie).toList();
  }

  bool get hasTies =>
      tiedRank().firstWhereOrNull((tie) => tie.length > 1) != null;
  bool get hasNoTies => !hasTies;

  List<List<MatchParticipant<P>?>> tiedRank();
}

/// A simple index into a [Ranking].
class Placement<P> {
  /// Creates the [Placement] of [place] inside the [ranking].
  Placement({
    required this.ranking,
    required this.place,
  });

  final int place;
  final Ranking<P> ranking;

  /// Returns the current occupant of [place] in [ranking].
  ///
  /// If the place is not occupied yet it returns null.
  MatchParticipant<P>? getPlacement() {
    List<MatchParticipant<P>?> ranks = ranking.rank();
    return ranks.elementAtOrNull(place);
  }
}
