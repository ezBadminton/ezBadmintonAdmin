import 'package:collection_repository/collection_repository.dart';

abstract class CollectionRepository<M extends Model> {
  /// Streams a [M] object whenever it is updated
  ///
  /// This happens when the [M] object was created, updated or deleted.
  Stream<CollectionUpdateEvent<M>> get updateStream;

  /// Fetches a single collection member by [id]
  ///
  /// Relations are expanded as defined by the [expand] `ExpansionTree`.
  Future<M> getModel(String id, {ExpansionTree? expand});

  /// Fetches the full list of [M] objects from their database collection.
  ///
  /// Relations are expanded as defined by the [expand] `ExpansionTree`.
  Future<List<M>> getList({ExpansionTree? expand});

  /// Adds a new instance of [M] to the [M]-collection.
  ///
  /// The returned created model has its relations [expand]ed
  Future<M> create(M newModel, {ExpansionTree? expand});

  /// Updates an existing instance of [M] identified by its 'id'.
  ///
  /// The returned updated model has its relations [expand]ed
  Future<M> update(M updatedModel, {ExpansionTree? expand});

  /// Deletes an existing instance of [M] identified by its 'id'.
  Future<void> delete(M deletedModel);

  /// Closes the update stream
  Future<void> dispose();
}

class CollectionUpdateEvent<M extends Model> {
  CollectionUpdateEvent.create(this.model) : updateType = UpdateType.create;
  CollectionUpdateEvent.update(this.model) : updateType = UpdateType.update;
  CollectionUpdateEvent.delete(this.model) : updateType = UpdateType.delete;

  final M model;
  final UpdateType updateType;
}

enum UpdateType { create, update, delete }

class CollectionQueryException {
  CollectionQueryException(this.errorCode);
  final String errorCode;
}
