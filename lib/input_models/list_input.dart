import 'package:collection/collection.dart';
import 'package:formz/formz.dart';

class ListInput<T> extends FormzInput<List<T>, Object> {
  const ListInput.pure([List<T> value = const []])
      : _pureList = value,
        super.pure(value);

  const ListInput._dirty(List<T> value, this._pureList) : super.dirty(value);

  final List<T> _pureList;

  ListInput<T> copyWith(List<T> list) {
    return ListInput._dirty(list, _pureList);
  }

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

  ListInput<T> copyWithAddedValue(T value) {
    return ListInput._dirty(
      List.of(this.value)..add(value),
      _pureList,
    );
  }

  ListInput<T> copyWithRemovedValue(T value) {
    return ListInput._dirty(
      List.of(this.value)..remove(value),
      _pureList,
    );
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
