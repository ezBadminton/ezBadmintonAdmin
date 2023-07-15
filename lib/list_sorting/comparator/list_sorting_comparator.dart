abstract class ListSortingComparator<T> {
  const ListSortingComparator({
    this.comparator = _noOpComparator,
    this.mode = ComparatorMode.ascending,
  });

  final Comparator<T> comparator;
  final ComparatorMode mode;

  ListSortingComparator<T> copyWith(ComparatorMode mode);

  static int _noOpComparator(dynamic a, dynamic b) => 0;
}

Comparator<T> reverseComparator<T>(Comparator<T> comparator) {
  return (a, b) => comparator(b, a);
}

/// Add a [secondary] comparator to a [primary] comparator.
///
/// The resulting nested comparator behaves as the [primary]
/// comparator except when that would return equality (`0`). In that case
/// the result of the [secondary] is returned.
Comparator<T> nestComparators<T>(
  Comparator<T> primary,
  Comparator<T> secondary,
) {
  return (a, b) {
    int result = primary(a, b);
    if (result == 0) {
      result = secondary(a, b);
    }
    return result;
  };
}

enum ComparatorMode { ascending, descending }
