import 'package:collection_repository/collection_repository.dart';

extension PlayingLevelCompare on PlayingLevel {
  /// Compares this [PlayingLevel] to another
  ///
  /// The value that is compared is [PlayingLevel.index]
  int compareTo(PlayingLevel other) {
    return index.compareTo(other.index);
  }

  /// Compares this [PlayingLevel] to a List of [PlayingLevel]s.
  ///
  /// Returns:
  /// - `1` if `this` is greater than all [others]
  /// - `0` if `this` lies within the bounds of [others] (inclusive)
  /// - `-1` if `this` is less than all [others]
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
