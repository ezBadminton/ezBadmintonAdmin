import 'package:collection/collection.dart';
import 'package:tournament_mode/src/match_participant.dart';

/// A class that ranks [MatchParticipant]s. It's not necessarily a ranking by
/// match results but can also be the result of a random or seeded draw.
abstract class Ranking<P> {
  List<MatchParticipant<P>>? _frozenRanks;

  List<MatchParticipant<P>> get ranks => _frozenRanks ?? createRanks();

  /// Returns a list of [MatchParticipant]s ordered by rank.
  List<MatchParticipant<P>> createRanks();

  /// Save the ranks as they are returned by [createRanks].
  ///
  /// After the ranking has been frozen [ranks] will return the saved ranks.
  ///
  /// This way the potentially expensive ranking calculations are only done
  /// once for the freeze.
  void freezeRanks() {
    _frozenRanks = createRanks();
  }

  void unfreezeRanks() {
    _frozenRanks = null;
  }
}

/// A simple index getter into a [Ranking].
class Placement<P> {
  /// Creates the [Placement] of [place] inside the [ranking].
  Placement({
    required this.ranking,
    required this.place,
  });

  final Ranking<P> ranking;
  final int place;

  /// Returns the current occupant of [place] in [ranking].
  ///
  /// If the place is not occupied it returns null.
  MatchParticipant<P>? getPlacement() {
    return ranking.ranks.elementAtOrNull(place);
  }
}
