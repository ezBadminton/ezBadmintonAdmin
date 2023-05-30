import 'package:collection_repository/collection_repository.dart';

abstract class CollectionRepository<M extends Model> {
  /// Streams a [M] object whenever it is updated
  ///
  /// This happens when the [M] object was created, updated or deleted.
  Stream<CollectionUpdateEvent<M>> get updateStream;

  /// Fetches the full list of [M] objects from their database collection.
  ///
  /// Relations are expanded as defined by the [expand] `ExpansionTree`.
  Future<List<M>> getList({ExpansionTree? expand});

  /// Adds a new instance of [M] to the [M]-collection.
  Future<M> create(M newModel);

  /// Updates an existing instance of [M] identified by its 'id'.
  Future<M> update(M updatedModel);

  /// Deletes an existing instance of [M] identified by its 'id'.
  Future<void> delete(M deletedModel);
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
