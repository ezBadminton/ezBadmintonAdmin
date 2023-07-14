abstract class ListSortingComparator<T> {
  const ListSortingComparator({
    this.comparator = _noOpComparator,
    this.mode = ComparatorMode.ascending,
  });

  final Comparator<T> comparator;
  final ComparatorMode mode;

  ListSortingComparator<T> copyWith(ComparatorMode mode);

  Comparator<T> reverseComparator(Comparator<T> comparator) {
    return (a, b) => comparator(b, a);
  }

  static int _noOpComparator(dynamic a, dynamic b) => 0;
}

enum ComparatorMode { ascending, descending }
