extension MoveableItem<T> on List<T> {
  /// Moves an item in this list [from] an index [to] another.
  ///
  /// Returns a copy with the item moved.
  List<T> moveItem(int from, int to) {
    T reorderedItem = this[from];
    if (to > from) {
      to += 1;
    }
    List<T> reorderedList = List.of(this)..insert(to, reorderedItem);
    if (to < from) {
      from += 1;
    }
    reorderedList.removeAt(from);

    return reorderedList;
  }
}
