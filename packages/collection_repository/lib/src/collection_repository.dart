import 'dart:async';

import 'package:collection_repository/collection_repository.dart';
import 'package:flutter/foundation.dart';

abstract class CollectionRepository<M extends Model> {
  /// Streams a [M] object whenever it is updated
  ///
  /// This happens when the [M] object was created, updated or deleted.
  Stream<CollectionUpdateEvent<M>> get updateStream;

  /// This stream emits events whenever anything changed in the collection.
  ///
  /// The difference to [updateStream] is that the [updateNotificationStream]
  /// does not carry the updated object, only reacts to updates
  /// (as opposed to creates and deletes) and only fires once when multiple
  /// objects have been updated at once.
  Stream<void> get updateNotificationStream;

  @protected
  StreamController<CollectionUpdateEvent<M>> get updateStreamController;

  @protected
  StreamController<void> get updateNotificationStreamController;

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
  ///
  /// When the update is part of a bigger update of mutliple models, then
  /// [isMulti] should be set to true. When the last of those updates occurs,
  /// additionally set [isFinalMulti] to true.
  /// This causes the [updateNotificationStream] to only emit one event when the
  /// final update happens instead of one norification event per single update.
  Future<M> update(
    M updatedModel, {
    ExpansionTree? expand,
    bool isMulti = false,
    bool isFinalMulti = false,
  });

  /// Deletes an existing instance of [M] identified by its 'id'.
  Future<void> delete(M deletedModel);

  /// Closes the update stream
  Future<void> dispose();

  void emitUpdateNotification() {
    updateNotificationStreamController.add(null);
  }
}

class CollectionUpdateEvent<M extends Model> {
  CollectionUpdateEvent.create(
    this.model, {
    this.isMulti = false,
    this.isFinalMulti = false,
  }) : updateType = UpdateType.create;
  CollectionUpdateEvent.update(
    this.model, {
    this.isMulti = false,
    this.isFinalMulti = false,
  }) : updateType = UpdateType.update;
  CollectionUpdateEvent.delete(
    this.model, {
    this.isMulti = false,
    this.isFinalMulti = false,
  }) : updateType = UpdateType.delete;

  final M model;
  final UpdateType updateType;

  final bool isMulti;
  final bool isFinalMulti;
}

enum UpdateType { create, update, delete }

class CollectionQueryException {
  CollectionQueryException(this.errorCode);
  final String errorCode;
}
