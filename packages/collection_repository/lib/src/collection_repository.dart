import 'dart:async';

import 'package:collection_repository/collection_repository.dart';
import 'package:flutter/foundation.dart';

abstract class CollectionRepository<M extends Model> {
  /// Streams a [M] object whenever it is updated
  ///
  /// This happens when the [M] object was created, updated or deleted.
  Stream<List<CollectionUpdateEvent<M>>> get updateStream;

  @protected
  StreamController<List<CollectionUpdateEvent<M>>> get updateStreamController;

  /// The load completer completes its future when the initial fetch of the
  /// collection was successful
  Completer<void> get loadCompleter;
  bool get isLoaded => loadCompleter.isCompleted;

  /// Triggers the initial collection load the should eventually complete
  /// the [loadCompleter].
  void load();

  /// Returns a single collection member by [id].
  ///
  /// An exception is thrown when this method is called before [isLoaded]
  /// becomes true.
  ///
  /// Returns null if the [id] cannot be found.
  M? getModel(String id);

  /// Returns the full collection of [M] objects.
  ///
  /// An exception is thrown when this method is called before [isLoaded]
  /// becomes true.
  ///
  /// The FutureOr is a Future when the [loadCompleter] is not completed yet.
  List<M> getList();

  /// Adds a new instance of [M] to the [M]-collection.
  ///
  /// The created model is returned.
  Future<M> create(
    M newModel, {
    Map<String, dynamic> query = const {},
  });

  /// Updates an existing instance of [M].
  ///
  /// Optionally [query] parameters can be set.
  ///
  /// The updated model is returned.
  Future<M> update(
    M updatedModel, {
    Map<String, dynamic> query = const {},
  });

  /// Deletes an existing instance of [M] identified by its 'id'.
  ///
  /// Optionally [query] parameters can be set.
  Future<void> delete(
    M deletedModel, {
    Map<String, dynamic> query = const {},
  });

  /// Sends a request to a collection-specific base route concatenated with the
  /// given [route].
  ///
  /// The [data] body and [query] parameters are the playload.
  ///
  /// For example the Person collection might have a base route of
  /// "/api/persons". When giving "/johndoe" as [route] the request will be
  /// made to "/api/persons/johndoe".
  ///
  /// Returns true when the response code is 200/OK.
  Future<bool> route({
    String route,
    String method,
    Map<String, dynamic> data = const {},
    Map<String, dynamic> query = const {},
  });

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
