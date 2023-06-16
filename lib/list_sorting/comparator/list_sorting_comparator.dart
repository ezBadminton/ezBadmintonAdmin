abstract class ListSortingComparator<T> {
  const ListSortingComparator({
    this.comparator,
    this.mode,
  });

  final Comparator<T>? comparator;
  final ComparatorMode? mode;

  ListSortingComparator<T> copyWith(ComparatorMode mode);

  Comparator<T> reverseComparator(Comparator<T> comparator) {
    return (a, b) => comparator(b, a);
  }
}

enum ComparatorMode { ascending, descending }
