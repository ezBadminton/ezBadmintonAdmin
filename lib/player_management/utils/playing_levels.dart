import 'package:collection_repository/collection_repository.dart';

extension PlayingLevelCompare on PlayingLevel {
  int compareTo(PlayingLevel other) {
    return index.compareTo(other.index);
  }

  int compareToList(List<PlayingLevel> others) {
    assert(others.isNotEmpty);
    var comparisons = others.map((lvl) => compareTo(lvl)).toSet();
    if (comparisons.length > 1) {
      return 0;
    } else {
      return comparisons.first;
    }
  }
}
