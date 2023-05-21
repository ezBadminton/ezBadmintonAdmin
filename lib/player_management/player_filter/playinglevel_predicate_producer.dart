import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_filter_cubit.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate_producer/predicate_producer.dart';

class PlayingLevelPredicateProducer extends PredicateProducer {
  static const String playingLevelDisjunction = 'playingLevel';
  final _playingLevels = <PlayingLevel>[];
  List<PlayingLevel> get playingLevels => List.unmodifiable(_playingLevels);

  void playingLevelToggled(PlayingLevel playingLevel) {
    FilterPredicate predicate;
    if (_playingLevels.contains(playingLevel)) {
      _playingLevels.remove(playingLevel);
      predicate = FilterPredicate(null, Player, '', playingLevel);
    } else {
      _playingLevels.add(playingLevel);
      playingLevelFilter(Object p) =>
          (p as Player).playingLevel == playingLevel;
      predicate = FilterPredicate(
        playingLevelFilter,
        Player,
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
