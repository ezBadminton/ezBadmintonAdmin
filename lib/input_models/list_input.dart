import 'package:collection/collection.dart';
import 'package:formz/formz.dart';

class ListInput<T> extends FormzInput<List<T>, Object> {
  const ListInput.pure([List<T> value = const []])
      : _pureList = value,
        super.pure(value);

  const ListInput._dirty(List<T> value, this._pureList) : super.dirty(value);

  ListInput<T> copyWith(List<T> list) {
    return ListInput._dirty(list, _pureList);
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

  final List<T> _pureList;

  @override
  Object? validator(List<T> value) {
    return null;
  }
}
