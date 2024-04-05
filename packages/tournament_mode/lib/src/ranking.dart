import 'package:collection/collection.dart';
import 'package:tournament_mode/src/match_participant.dart';

/// A class that ranks [MatchParticipant]s. It's not necessarily a ranking by
/// match results but can also be the result of a random or seeded draw.
abstract class Ranking<P> {
  List<MatchParticipant<P>>? _ranks;

  /// The [Ranking]s that are influenced by this ranking.
  ///
  /// The rankings thus form a directed acyclic graph. Updates to a ranking
  /// propagate through this graph.
  final List<Ranking<P>> _dependantRankings = [];
  List<Ranking<P>> get dependantRankings =>
      List.unmodifiable(_dependantRankings);

  /// The dependent participants are participants who resolve their
  /// player from this ranking.
  final List<MatchParticipant<P>> _dependantParticipants = [];
  List<MatchParticipant<P>> get dependantParticipants =>
      List.unmodifiable(_dependantParticipants);

  List<MatchParticipant<P>> get ranks {
    if (_ranks == null) {
      update();
    }
    return _ranks!;
  }

  /// Returns a list of [MatchParticipant]s ordered by rank.
  List<MatchParticipant<P>> createRanks();

  /// Update the ranks then update the dependant participants.
  void update() {
    updateRanks();
    updateParticipants();
  }

  void updateRanks() {
    _ranks = createRanks();
  }

  void updateParticipants() {
    for (MatchParticipant<P> participant in _dependantParticipants) {
      participant.updatePlayer();
    }
  }

  void addDependantRanking(Ranking<P> ranking) {
    _dependantRankings.add(ranking);
  }

  /// Registers a [MatchParticipant.fromPlacement] as a dependant of this
  /// ranking.
  ///
  /// The dependants get their [MatchParticipant.updatePlayer] method called
  /// when [update] is called.
  void addDependantParticipant(MatchParticipant<P> participant) {
    _dependantParticipants.add(participant);
  }

  MatchParticipant<P>? getExistingDependant(Placement<P> placement) {
    if (placement.ranking != this) {
      return null;
    }

    return _dependantParticipants
        .firstWhereOrNull((p) => p.placement?.place == placement.place);
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
