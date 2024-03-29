import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/filter_predicate.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/predicate_producer.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate_producers.dart';

class PlayingLevelPredicateProducer extends PredicateProducer {
  static const FilterGroup playingLevelDisjunction = FilterGroup.playingLevel;
  final _playingLevels = <PlayingLevel>[];
  List<PlayingLevel> get playingLevels => List.unmodifiable(_playingLevels);

  void playingLevelToggled(PlayingLevel playingLevel) {
    FilterPredicate predicate;
    if (_playingLevels.contains(playingLevel)) {
      _playingLevels.remove(playingLevel);
      predicate = FilterPredicate(null, Competition, '', playingLevel);
    } else {
      _playingLevels.add(playingLevel);
      playingLevelFilter(Object c) {
        return (c as Competition).playingLevel == playingLevel;
      }

      predicate = FilterPredicate(
        playingLevelFilter,
        Competition,
        playingLevel.name,
        playingLevel,
        playingLevelDisjunction,
      );
    }

    predicateStreamController.add(predicate);
  }

  @override
  void produceEmptyPredicate(dynamic predicateDomain) {
    if (producesDomain(predicateDomain) &&
        _playingLevels.contains(predicateDomain)) {
      playingLevelToggled(predicateDomain);
    }
  }

  @override
  bool producesDomain(dynamic predicateDomain) {
    return predicateDomain is PlayingLevel;
  }
}
