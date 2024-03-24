import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';

/// A [CollectionRepository] holding the collection in memory for testing
/// purposes.
class TestCollectionRepository<M extends Model>
    extends CollectionRepository<M> {
  TestCollectionRepository({
    List<M> initialCollection = const [],
    this.throwing = false,
    this.responseDelay,
    this.loadTime = Duration.zero,
  }) {
    _loadTime(initialCollection);
  }

  /// If any calls to the repository should throw
  bool throwing;

  /// When not null, all calls are answered with this delay
  /// (to simulate network delay for example)
  final Duration? responseDelay;

  /// The duration after which the [loadCompleter] will be completed.
  final Duration loadTime;

  @override
  final Completer<void> loadCompleter = Completer();

  List<M> collection = [];

  @override
  Stream<List<CollectionUpdateEvent<M>>> get updateStream async* {
    yield* updateStreamController.stream;
  }

  @override
  final StreamController<List<CollectionUpdateEvent<M>>>
      updateStreamController = StreamController.broadcast();

  @override
  List<M> getList() {
    return List.unmodifiable(collection);
  }

  @override
  M getModel(String id) {
    M? model = collection.firstWhereOrNull((m) => m.id == id);
    if (model == null) {
      throw Exception("Tried to get non-existent model by id");
    }
    return model;
  }

  @override
  Future<M> create(
    M newModel, {
    Map<String, dynamic> query = const {},
  }) async {
    _testThrow();
    await _delayResponse();
    if (collection.contains(newModel)) {
      throw Exception("Tried to re-add existing model");
    }
    M createdModel = (newModel as dynamic).copyWith(id: _createId());
    collection.add(createdModel);
    updateStreamController.add([CollectionUpdateEvent.create(createdModel)]);
    return createdModel;
  }

  @override
  Future<M> update(
    M updatedModel, {
    Map<String, dynamic> query = const {},
  }) async {
    _testThrow();
    await _delayResponse();
    if (collection.firstWhereOrNull((m) => m.id == updatedModel.id) == null) {
      throw Exception("Tried to update non-existent model");
    }
    collection.removeWhere((m) => m.id == updatedModel.id);
    collection.add(updatedModel);
    updateStreamController.add([CollectionUpdateEvent.update(updatedModel)]);
    return updatedModel;
  }

  @override
  Future<void> delete(
    M deletedModel, {
    Map<String, dynamic> query = const {},
  }) async {
    _testThrow();
    await _delayResponse();
    if (!collection.contains(deletedModel)) {
      throw Exception("Tried to delete non-existent model");
    }
    collection.remove(deletedModel);
    updateStreamController.add([CollectionUpdateEvent.delete(deletedModel)]);
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
      throw CollectionQueryException('Test error message');
    }
  }

  Future<void> _delayResponse() async {
    if (responseDelay != null) {
      return Future.delayed(responseDelay!);
    }
  }

  void _loadTime(List<M> initialCollection) async {
    await Future.delayed(loadTime);
    if (throwing) {
      loadCompleter.completeError("Test error message");
    } else {
      collection = List.of(initialCollection);
      loadCompleter.complete();
    }
  }

  @override
  Future<bool> route({
    String route = "",
    String method = "GET",
    Map<String, dynamic> data = const {},
    Map<String, dynamic> query = const {},
  }) {
    throw UnimplementedError();
  }
}
