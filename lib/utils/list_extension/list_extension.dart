import 'package:collection/collection.dart';
import 'package:model_repository/model_repository.dart';

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

extension ModelReplacement<M extends Model> on List<M> {
  /// Replaces the [Model] with the [id] with the [replacement].
  ///
  /// When [replacement] is null, it just removes the [Model] with [id].
  /// Does nothing if the list does not contain a model with the [id].
  void replaceModel(String id, M? replacement) {
    int index = indexWhere((m) => m.id == id);
    if (index >= 0) {
      if (replacement == null) {
        removeAt(index);
      } else {
        this[index] = replacement;
      }
    }
  }
}

extension ModelUpdateUtils on List<CollectionUpdateEvent> {
  /// Returns the latest version the [model] (equality by id) according to
  /// this list of updates. If none of the updates contains the [model] null
  /// is returned.
  M? latestVersion<M extends Model>(M? model) {
    if (model == null) {
      return null;
    }
    return lastWhereOrNull((updateEvent) => updateEvent.model == model)?.model
        as M;
  }

  CollectionUpdateEvent<M>? latestUpdate<M extends Model>(M? model) {
    if (model == null) {
      return null;
    }
    return lastWhereOrNull((updateEvent) => updateEvent.model == model)
        as CollectionUpdateEvent<M>;
  }
}
