import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';

class TestCollectionRepository<M extends Model>
    implements CollectionRepository<M> {
  TestCollectionRepository({
    List<M> initialCollection = const [],
    this.throwing = false,
  }) : collection = List.of(initialCollection);

  final bool throwing;

  List<M> collection;

  @override
  Stream<CollectionUpdateEvent<M>> get updateStream async* {
    yield* updateStreamController.stream;
  }

  @override
  final StreamController<CollectionUpdateEvent<M>> updateStreamController =
      StreamController.broadcast();

  @override
  Future<List<M>> getList({ExpansionTree? expand}) async {
    _testThrow();
    return List.of(collection);
  }

  @override
  Future<M> getModel(String id, {ExpansionTree? expand}) async {
    _testThrow();
    M? model = collection.firstWhereOrNull((m) => m.id == id);
    if (model == null) {
      throw Exception("Tried to get non-existent model by id");
    }
    return model;
  }

  @override
  Future<M> create(M newModel, {ExpansionTree? expand}) async {
    _testThrow();
    if (collection.contains(newModel)) {
      throw Exception("Tried to re-add existing model");
    }
    M createdModel = (newModel as dynamic).copyWith(id: _createId());
    collection.add(createdModel);
    updateStreamController.add(CollectionUpdateEvent.create(createdModel));
    return createdModel;
  }

  @override
  Future<M> update(M updatedModel, {ExpansionTree? expand}) async {
    _testThrow();
    if (collection.firstWhereOrNull((m) => m.id == updatedModel.id) == null) {
      throw Exception("Tried to update non-existent model");
    }
    collection.removeWhere((m) => m.id == updatedModel.id);
    collection.add(updatedModel);
    updateStreamController.add(CollectionUpdateEvent.update(updatedModel));
    return updatedModel;
  }

  @override
  Future<void> delete(M deletedModel) async {
    _testThrow();
    if (!collection.contains(deletedModel)) {
      throw Exception("Tried to delete non-existent model");
    }
    collection.remove(deletedModel);
    updateStreamController.add(CollectionUpdateEvent.delete(deletedModel));
  }

  @override
  Future<void> dispose() {
    throw UnimplementedError();
  }

  String _createId() {
    String id = '';

    while (
        id.isEmpty || collection.firstWhereOrNull((m) => m.id == id) != null) {
      const chars =
          'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789';
      Random r = Random();
      id = String.fromCharCodes(
        Iterable.generate(15, (_) => chars.codeUnitAt(r.nextInt(chars.length))),
      );
    }

    return id;
  }

  void _testThrow() {
    if (throwing) {
      throw CollectionQueryException('errorMessage');
    }
  }
}
