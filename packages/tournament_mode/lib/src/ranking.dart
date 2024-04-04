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
  final List<MatchParticipant<P>> _dependentParticipants = [];

  List<MatchParticipant<P>> get ranks {
    if (_ranks == null) {
      updateRanks();
    }
    return _ranks!;
  }

  /// Returns a list of [MatchParticipant]s ordered by rank.
  List<MatchParticipant<P>> createRanks();

  /// Update the ranks by calling [createRanks].
  void updateRanks() {
    _ranks = createRanks();

    for (MatchParticipant<P> participant in _dependentParticipants) {
      participant.updatePlayer();
    }
  }

  void addDependantRanking(Ranking<P> ranking) {
    _dependantRankings.add(ranking);
  }

  /// Registers a [MatchParticipant.fromPlacement] that has this ranking as its
  /// [Placement.ranking].
  ///
  /// The dependants get their [MatchParticipant.updatePlayer] method called
  /// when [updateRanks] is called.
  void registerDependantParticipant(MatchParticipant<P> participant) {
    assert(participant.placement?.ranking == this);
    _dependentParticipants.add(participant);
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
