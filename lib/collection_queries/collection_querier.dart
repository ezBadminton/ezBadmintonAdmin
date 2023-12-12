import 'dart:async';

import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef FetcherFunction<M extends Model> = Future<List<M>?> Function();

class CollectionQuerier {
  /// A class that has functions to fetch and update collections from db.
  ///
  /// The collections are accessed via [CollectionRepository] objects given
  /// by [collectionRepositories]. Each repository object is granting access to
  /// a collection of one [Model].
  ///
  /// Example:
  /// ```dart
  /// CollectionRepository<Player> playerRepository = ...; // Usually injected by a repository provider
  /// CollectionRepository<Team> teamRepository = ...;
  /// var querier = CollectionQuerier(
  ///   [
  ///     playerRepository,
  ///     teamRepository,
  ///   ],
  /// );
  ///
  /// // Fetch Player collection in some async function:
  /// List<Player>? players = await querier.fetchCollection<Player>();
  /// ```
  ///
  /// The `querier` now has the ability to fetch [Player] and [Team]
  /// collections. Beware trying to do collection operations
  /// on Models that the [CollectionQuerier] does not have the repository
  /// of. This will lead to exceptions.
  CollectionQuerier(this.collectionRepositories);

  final Iterable<CollectionRepository<Model>> collectionRepositories;

  /// Fetches one model from collection of data objects of the model type [M]
  ///
  /// The Future resolves to null if the collection db can't be reached.
  /// Use an [ExpansionTree] as the [expand] parameter to also fetch the related
  /// models of [M]. Some [Model]s have default expansions defined by the
  /// repository.
  Future<M?> fetchModel<M extends Model>(
    String id, {
    ExpansionTree? expand,
  }) async {
    assert(
      collectionRepositories.whereType<CollectionRepository<M>>().isNotEmpty,
      'The CollectionQuerier does not have the ${M.toString()} repository',
    );
    var collectionRepository =
        collectionRepositories.whereType<CollectionRepository<M>>().first;

    try {
      return await collectionRepository.getModel(id, expand: expand);
    } on CollectionQueryException {
      return null;
    }
  }

  /// Fetches the full collection of data objects of the model type [M]
  ///
  /// The Future resolves to null if the collection db can't be reached.
  /// Use an [ExpansionTree] as the [expand] parameter to also fetch the related
  /// models of [M]. Some [Model]s have default expansions defined by the
  /// repository.
  Future<List<M>?> fetchCollection<M extends Model>({
    ExpansionTree? expand,
  }) async {
    assert(
      collectionRepositories.whereType<CollectionRepository<M>>().isNotEmpty,
      'The CollectionQuerier does not have the ${M.toString()} repository',
    );
    var collectionRepository =
        collectionRepositories.whereType<CollectionRepository<M>>().first;
    try {
      return await collectionRepository.getList(
        expand: expand,
      );
    } on CollectionQueryException {
      return null;
    }
  }

  /// Fetches multiple collections at once and returns them as a [List].
  ///
  /// The list contains null where the collection could not be fetched.
  ///
  /// Example:
  /// ```dart
  /// fetchCollections([fetchCollection<Player>, fetchCollection<Team>]);
  /// ```
  Future<List<List<Model>?>> fetchCollections(
    Iterable<FetcherFunction> fetcherFunctions,
  ) async {
    var fetchResults =
        await Future.wait([for (var fetcher in fetcherFunctions) fetcher()]);
    return fetchResults;
  }

  /// Puts a newly created model into its collection on the DB.
  ///
  /// On success the Future resolves to the [Model] of type [M] with its
  /// `id`, `created` and `updated` fields set.
  /// Otherwise null if the collection db can't be reached.
  Future<M?> createModel<M extends Model>(
    M newModel, {
    ExpansionTree? expand,
  }) async {
    assert(
      collectionRepositories.whereType<CollectionRepository<M>>().isNotEmpty,
      'The CollectionQuerier does not have the ${M.toString()} repository',
    );
    assert(newModel.id.isEmpty);
    var collectionRepository =
        collectionRepositories.whereType<CollectionRepository<M>>().first;

    try {
      return await collectionRepository.create(newModel, expand: expand);
    } on CollectionQueryException {
      return null;
    }
  }

  /// Creates a list of models
  ///
  /// Resolves to a list of the created models
  Future<List<M?>> createModels<M extends Model>(
    List<M> models, {
    ExpansionTree? expand,
  }) async {
    Iterable<Future<M?>> modelCreations =
        models.map((model) => createModel(model));
    List<M?> createdModels = await Future.wait(modelCreations);

    return createdModels;
  }

  /// Updates a model in its collection on the DB.
  ///
  /// On success the Future resolves to the [Model] of type [M] with its
  /// new `updated` timestamp.
  /// Otherwise `null` if the collection db can't be reached.
  Future<M?> updateModel<M extends Model>(
    M updatedModel, {
    ExpansionTree? expand,
    bool isMulti = false,
    bool isFinalMulti = false,
  }) async {
    assert(
      collectionRepositories.whereType<CollectionRepository<M>>().isNotEmpty,
      'The CollectionQuerier does not have the ${M.toString()} repository',
    );
    assert(updatedModel.id.isNotEmpty);
    var collectionRepository =
        collectionRepositories.whereType<CollectionRepository<M>>().first;

    try {
      return await collectionRepository.update(
        updatedModel,
        expand: expand,
        isMulti: isMulti,
        isFinalMulti: isFinalMulti,
      );
    } on CollectionQueryException {
      return null;
    }
  }

  /// Updates or creates the given model based on wether it already has an `id`.
  Future<M?> updateOrCreateModel<M extends Model>(
    M model, {
    ExpansionTree? expand,
  }) {
    if (model.id.isEmpty) {
      return createModel(model, expand: expand);
    } else {
      return updateModel(model, expand: expand);
    }
  }

  /// Updates a list of models
  ///
  /// Resolves to a list of the updated models
  Future<List<M?>> updateModels<M extends Model>(
    List<M> models, {
    ExpansionTree? expand,
  }) async {
    // This just calls [updateModel] for each list item. Sadly pocketbase
    // doesn't support transactional bulk operations yet. Keep an eye on
    // https://github.com/pocketbase/pocketbase/issues/48 where this will be
    // added.
    Iterable<Future<M?>> modelUpdates = models.mapIndexed((index, model) {
      bool isFinal = index == (models.length - 1);

      return updateModel(
        model,
        expand: expand,
        isMulti: true,
        isFinalMulti: isFinal,
      );
    });
    List<M?> updatedModels = await Future.wait(modelUpdates);

    collectionRepositories
        .whereType<CollectionRepository<M>>()
        .first
        .emitUpdateNotification();

    return updatedModels;
  }

  /// Deletes a model from its collection on the DB.
  ///
  /// On success the future resolves to `true` otherwise `false`.
  Future<bool> deleteModel<M extends Model>(M deletedModel) async {
    assert(
      collectionRepositories.whereType<CollectionRepository<M>>().isNotEmpty,
      'The CollectionQuerier does not have the ${M.toString()} repository',
    );
    var collectionRepository =
        collectionRepositories.whereType<CollectionRepository<M>>().first;

    try {
      await collectionRepository.delete(deletedModel);
      return true;
    } on CollectionQueryException {
      return false;
    }
  }

  /// Deletes a list of models
  ///
  /// Resolves to `true` when all models have successfully been deleted
  Future<bool> deleteModels<M extends Model>(List<M> deletedModels) async {
    Iterable<Future<bool>> modelDeletions =
        deletedModels.map((model) => deleteModel(model));
    List<bool> modelsDeleted = await Future.wait(modelDeletions);

    return !modelsDeleted.contains(false);
  }
}

class CollectionQuerierCubit<State> extends Cubit<State> {
  /// A Cubit that has a [CollectionQuerier] member.
  ///
  /// The [CollectionQuerier] is created with the given [collectionRepositories]
  /// and can be used by accessing the `querier` field.
  CollectionQuerierCubit(
    super.initialState, {
    required Iterable<CollectionRepository<Model>> collectionRepositories,
  }) : querier = CollectionQuerier(collectionRepositories);

  final CollectionQuerier querier;

  final List<StreamSubscription> collectionUpdateSubscriptions = [];

  /// Listens to updates in the collection of [M] via the [repository].
  ///
  /// The [listener] is called with a [CollectionUpdateEvent] whenever another
  /// part of the app does an operation in the collection.
  ///
  /// The resulting [StreamSubscription] is automatically closed when the
  /// cubit closes. This happens automatically when the cubit was created by a
  /// [BlocProvider].
  void subscribeToCollectionUpdates<M extends Model>(
    CollectionRepository<M> repository,
    void Function(CollectionUpdateEvent<M> updateEvent)? listener,
  ) {
    StreamSubscription subscription = repository.updateStream.listen(listener);
    collectionUpdateSubscriptions.add(subscription);
  }

  void subscribeToCollectionUpdateNotifications<M extends Model>(
    CollectionRepository<M> repository,
    VoidCallback? listener,
  ) {
    StreamSubscription subscription =
        repository.updateNotificationStream.listen((_) => listener?.call());
    collectionUpdateSubscriptions.add(subscription);
  }

  @override
  Future<void> close() async {
    for (StreamSubscription subscription in collectionUpdateSubscriptions) {
      subscription.cancel();
    }
    return super.close();
  }
}

class CollectionFetcherCubit<State extends CollectionFetcherState<State>>
    extends CollectionQuerierCubit<State> {
  /// A CollectionQuerierCubit that can update its [CollectionFetcherState]
  /// with fetched collections.
  CollectionFetcherCubit(
    super.initialState, {
    required super.collectionRepositories,
  });

  /// Returns a [CollectionFetcher] object.
  CollectionFetcher collectionFetcher<M extends Model>({
    ExpansionTree? expand,
  }) {
    return CollectionFetcher<M>(
      fetcherFunction: () => querier.fetchCollection<M>(expand: expand),
    );
  }

  /// Uses the given [fetchers] to fetch multiple collections and store
  /// them as state.
  ///
  /// If all given fetchers were able to get the collection, the [onSuccess]
  /// callback is called with the updated state. Otherwise [onFailure].
  ///
  /// Example usage:
  /// ```dart
  /// fetchCollectionsAndUpdateState(
  ///   [
  ///     // Fetch the collections of Player and Team data models
  ///     collectionFetcher<Player>(),
  ///     collectionFetcher<Team>(),
  ///   ],
  ///   onSuccess: (updatedState) {
  ///     // Let state listeners know the data has been loaded
  ///     emit(updatedState);
  ///   },
  ///   onFailure: () {
  ///     // Emit some loading failure state
  ///   },
  /// );
  /// ```
  void fetchCollectionsAndUpdateState(
    Iterable<CollectionFetcher> fetchers, {
    void Function(State updatedState)? onSuccess,
    void Function()? onFailure,
  }) async {
    var fetchResults =
        await querier.fetchCollections(fetchers.map((f) => f.fetcherFunction));
    if (fetchResults.contains(null)) {
      if (onFailure != null && !isClosed) {
        onFailure();
      }
    } else {
      var updatedState = state;
      int i = 0;
      for (var collection in fetchResults) {
        updatedState = updatedState.copyWithCollection(
          modelType: fetchers.elementAt(i).modelType,
          collection: collection!,
        );
        i += 1;
      }
      if (onSuccess != null && !isClosed) {
        onSuccess(updatedState);
      }
    }
  }
}

/// A state object that holds the fetched collections of a
/// [CollectionFetcherCubit].
///
/// The [copyWithCollection] method requires the inheriting class to have a
/// `copyWith` method with a named `collections` parameter.
abstract class CollectionFetcherState<I extends CollectionFetcherState<I>> {
  const CollectionFetcherState({required this.collections});

  /// The collections that have been fetched.
  ///
  /// Maps the specific [Model] subtypes to their collections.
  final Map<Type, List<Model>> collections;

  /// Returns the fetched collection of model type [M].
  ///
  /// Calling with a model type that this fetcher state does not hold results
  /// in an error.
  List<M> getCollection<M extends Model>() {
    assert(
      collections.keys.contains(M),
      'The CollectionFetcherState does not hold the ${M.toString()} collection.',
    );
    return collections[M] as List<M>;
  }

  /// Returns a copy with added [collection] of [modelType].
  ///
  /// Replaces possibly present collection of [modelType]
  I copyWithCollection<M extends Model>({
    required Type modelType,
    required List<M> collection,
  }) {
    Map<Type, List<Model>> updatedCollections = Map.of(collections);
    updatedCollections.remove(modelType);
    updatedCollections.putIfAbsent(modelType, () => collection);
    updatedCollections = Map.unmodifiable(updatedCollections);

    // Assert existence of copyWith method. Done to be able to
    // copy the members of the inheriting class [I].
    assert(
      (this as dynamic).copyWith(collections: updatedCollections) is I,
      'Subclasses of CollectionFetcherState have to implement a copyWith method with a named `collections` parameter',
    );
    return (this as dynamic).copyWith(collections: updatedCollections);
  }
}

class CollectionFetcher<M extends Model> {
  /// A [CollectionFetcher] connects a [FetcherFunction] with a [Model] type [M].
  ///
  /// This way the [FetcherFunction]'s returned List of Models can still be
  /// known by its specific [modelType] outside of the scope of the
  /// [FetcherFunction]'s generic type parameter.
  CollectionFetcher({required this.fetcherFunction});
  final FetcherFunction fetcherFunction;
  Type get modelType => M;
}
