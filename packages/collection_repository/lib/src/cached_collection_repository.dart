import 'dart:async';

import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:collection_repository/src/collection_repository_decorator.dart';

class CachedCollectionRepository<M extends Model>
    extends CollectionRepositoryDecorator<M> {
  /// A CollectionRepository decorator that caches fetched models and
  /// returns them instead of querying the database.
  ///
  /// The [targetCollectionRepository] handles the queries in
  /// case of a cache miss.
  ///
  /// Optionally a list of [relationRepositories] together with a
  /// [relationUpdateHandler] function can be passed in. This is useful for
  /// updating the cached models or clearing the cache when other collections
  /// update.
  CachedCollectionRepository(
    super.targetCollectionRepository, {
    List<CollectionRepository>? relationRepositories,
    this.relationUpdateHandler,
  }) : assert(
          (relationRepositories == null) == (relationUpdateHandler == null),
        ) {
    if (relationRepositories != null) {
      _relationUpdateStreamSubscriptions = relationRepositories
          .map((r) => r.updateStream.listen(_onRelationUpdate))
          .toList();
    } else {
      _relationUpdateStreamSubscriptions = [];
    }
  }

  /// The optional relation update handler receives all update events from the
  /// [relationRepositories] and the current cached collection.
  ///
  /// It returns a list of all updated models in the collection that had one
  /// of their related models updated.
  /// The updated models are then adopted into the cache.
  final List<M> Function(List<M> collection, CollectionUpdateEvent updateEvent)?
      relationUpdateHandler;

  late final List<StreamSubscription> _relationUpdateStreamSubscriptions;

  List<M> _cachedCollection = [];
  bool _entireCollectionCached = false;

  @override
  Stream<CollectionUpdateEvent<M>> get updateStream =>
      targetCollectionRepository.updateStream;

  @override
  Stream<void> get updateNotificationStream =>
      targetCollectionRepository.updateNotificationStream;

  @override
  StreamController<CollectionUpdateEvent<M>> get updateStreamController =>
      targetCollectionRepository.updateStreamController;

  @override
  StreamController<void> get updateNotificationStreamController =>
      targetCollectionRepository.updateNotificationStreamController;

  @override
  Future<M> getModel(String id, {ExpansionTree? expand}) async {
    var cached = _cachedCollection.singleWhereOrNull(
      (model) => model.id == id,
    );
    if (cached != null) {
      return cached;
    } else {
      var model = await targetCollectionRepository.getModel(id, expand: expand);
      _cachedCollection.add(model);
      assert(_cachedCollection.where((e) => e.id == id).length == 1);
      return model;
    }
  }

  @override
  Future<List<M>> getList({ExpansionTree? expand}) async {
    if (_entireCollectionCached) {
      return List.of(_cachedCollection);
    } else {
      var collection = await targetCollectionRepository.getList(expand: expand);
      _cachedCollection = List.of(collection);
      _entireCollectionCached = true;
      return collection;
    }
  }

  @override
  Future<M> create(M newModel, {ExpansionTree? expand}) async {
    var createdModelFromDB = await targetCollectionRepository.create(
      newModel,
      expand: expand,
    );
    _cachedCollection.add(createdModelFromDB);
    return createdModelFromDB;
  }

  @override
  Future<M> update(
    M updatedModel, {
    ExpansionTree? expand,
    bool isMulti = false,
    bool isFinalMulti = false,
  }) async {
    var updatedModelFromDB = await targetCollectionRepository.update(
      updatedModel,
      expand: expand,
      isMulti: isMulti,
      isFinalMulti: isFinalMulti,
    );
    _cachedCollection
      ..removeWhere((m) => m.id == updatedModelFromDB.id)
      ..add(updatedModelFromDB);
    return updatedModelFromDB;
  }

  @override
  Future<void> delete(M deletedModel) async {
    await targetCollectionRepository.delete(deletedModel);
    _cachedCollection.removeWhere((m) => m.id == deletedModel.id);
  }

  void _updateCache(
    M updatedModel, {
    required bool isMulti,
    required bool isFinalMulti,
  }) {
    _cachedCollection
      ..removeWhere((m) => m.id == updatedModel.id)
      ..add(updatedModel);

    updateStreamController.add(CollectionUpdateEvent.update(
      updatedModel,
      isMulti: isMulti,
      isFinalMulti: isFinalMulti,
    ));
    if (!isMulti || isFinalMulti) {
      updateNotificationStreamController.add(null);
    }
  }

  void _onRelationUpdate(CollectionUpdateEvent updateEvent) async {
    List<M> updatedModels = relationUpdateHandler!(
      await getList(),
      updateEvent,
    );
    for (M model in updatedModels) {
      _updateCache(
        model,
        isMulti: updateEvent.isMulti,
        isFinalMulti: updateEvent.isFinalMulti,
      );
    }
  }

  @override
  Future<void> dispose() {
    for (StreamSubscription subscription
        in _relationUpdateStreamSubscriptions) {
      subscription.cancel();
    }
    return targetCollectionRepository.dispose();
  }
}
