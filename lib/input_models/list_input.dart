import 'package:collection/collection.dart';
import 'package:formz/formz.dart';

class ListInput<T> extends FormzInput<List<T>, Object> {
  const ListInput.pure([List<T> value = const []])
      : _pureList = value,
        super.pure(value);

  const ListInput._dirty(List<T> value, this._pureList) : super.dirty(value);

  final List<T> _pureList;

  /// Returns a dirty [ListInput] with the [list] as its value.
  ///
  /// The pure base list stays the same.
  ListInput<T> copyWith(List<T> list) {
    return ListInput._dirty(list, _pureList);
  }

  /// Returns a [ListInput] with [value] replaced by [replaceWith].
  /// This also replaces the value in the pure list. So pure lists stay pure
  /// and dirty lists get a new pure base.
  ListInput<T> copyWithReplacedValue(T value, T replaceWith) {
    List<T> newList = this.value;
    if (newList.contains(value)) {
      newList = List.of(this.value)
        ..remove(value)
        ..add(replaceWith);
    }
    List<T> newPureList = _pureList;
    if (newPureList.contains(value)) {
      newPureList = List.of(_pureList)
        ..remove(value)
        ..add(replaceWith);
    }
    if (isPure) {
      return ListInput.pure(newPureList);
    } else {
      return ListInput._dirty(newList, newPureList);
    }
  }

  /// Returns a dirty [ListInput] with [value] added.
  ListInput<T> copyWithAddedValue(T value) {
    return ListInput._dirty(
      List.of(this.value)..add(value),
      _pureList,
    );
  }

  /// Returns a dirty [ListInput] with [value] removed. If the list did not
  /// contain the [value], the returned [ListInput] is still dirty.
  ListInput<T> copyWithRemovedValue(T value) {
    return ListInput._dirty(
      List.of(this.value)..remove(value),
      _pureList,
    );
  }

  /// Returns a pure version of this list input with all dirty changes undone.
  ListInput<T> copyWithReset() {
    return ListInput.pure(_pureList);
  }

  /// Returns a pure version of this list input with the dirty changes applied.
  ListInput<T> copyAsPure() {
    return ListInput.pure(value);
  }

  /// Returns the values that have been added to the list since it was pure
  List<T> getAddedElements() {
    return value.whereNot((e) => _pureList.contains(e)).toList();
  }

  /// Returns the values that have been removed from the list since it was pure
  List<T> getRemovedElements() {
    return _pureList.whereNot((e) => value.contains(e)).toList();
  }

  @override
  Object? validator(List<T> value) {
    return null;
  }
}
