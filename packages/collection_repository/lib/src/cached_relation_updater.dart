import 'dart:async';

import 'package:collection_repository/collection_repository.dart';

/// Propagates updates of related fields in a [CachedCollectionRepository]
class CachedRelationUpdater<M extends Model> {
  CachedRelationUpdater({
    required this.targetCachedCollectionRepository,
    required List<CollectionRepository> relationRepositories,
    required this.updateHandler,
  }) {
    _updateStreamSubscriptions = relationRepositories
        .map((s) => s.updateStream.listen(onRelationUpdate))
        .toList();
  }

  /// The [CachedCollectionRepository] to propagate the updates to
  ///
  /// Its cached models will be updated by the [updateHandler].
  final CachedCollectionRepository<M> targetCachedCollectionRepository;

  /// The update handler receives all update events from the
  /// [relationRepositories] and the current cached collection.
  ///
  /// It returns a list of all updated models in the collection that had one
  /// of their related models updated.
  /// The updated models are then adopted into the cache.
  final List<M> Function(List<M> collection, CollectionUpdateEvent updateEvent)
      updateHandler;

  late final List<StreamSubscription> _updateStreamSubscriptions;

  /// Gets called on each update
  void onRelationUpdate(CollectionUpdateEvent updateEvent) async {
    List<M> updatedModels = updateHandler(
      await targetCachedCollectionRepository.getList(),
      updateEvent,
    );
    for (M model in updatedModels) {
      targetCachedCollectionRepository.updateCache(model);
    }
  }

  void dispose() {
    for (StreamSubscription subscription in _updateStreamSubscriptions) {
      subscription.cancel();
    }
  }
}
