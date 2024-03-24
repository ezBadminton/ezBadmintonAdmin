import 'dart:async';

import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef FetcherFunction<M extends Model> = FutureOr<List<M>> Function();

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

  /// Gets one model from the [M]-collection by [id].
  ///
  /// Returns `null` if that [id] doesn't exist
  M? getModel<M extends Model>(String id) {
    var collectionRepository = getRepository<M>();

    return collectionRepository.getModel(id);
  }

  /// Gets the full [M]-collection
  List<M> getCollection<M extends Model>() {
    var collectionRepository = getRepository<M>();

    return collectionRepository.getList();
  }

  /// Puts a newly created model into its collection on the DB.
  ///
  /// On success the Future resolves to the [Model] of type [M] with its
  /// `id`, `created` and `updated` fields set.
  /// Otherwise null if the collection db can't be reached.
  Future<M?> createModel<M extends Model>(
    M newModel, {
    Map<String, dynamic> query = const {},
  }) async {
    assert(newModel.id.isEmpty);
    var collectionRepository = getRepository<M>();

    try {
      return await collectionRepository.create(newModel, query: query);
    } on CollectionQueryException {
      return null;
    }
  }

  /// Creates a list of models
  ///
  /// Resolves to a list of the created models
  Future<List<M?>> createModels<M extends Model>(List<M> models) async {
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
    Map<String, dynamic> query = const {},
  }) async {
    assert(updatedModel.id.isNotEmpty);
    var collectionRepository = getRepository<M>();

    try {
      return await collectionRepository.update(updatedModel, query: query);
    } on CollectionQueryException {
      return null;
    }
  }

  /// Updates or creates the given model based on wether it already has an `id`.
  Future<M?> updateOrCreateModel<M extends Model>(
    M model, {
    Map<String, dynamic> query = const {},
  }) {
    if (model.id.isEmpty) {
      return createModel(model, query: query);
    } else {
      return updateModel(model, query: query);
    }
  }

  /// Updates a list of models
  ///
  /// Resolves to a list of the updated models
  Future<List<M?>> updateModels<M extends Model>(List<M> models) async {
    // This just calls [updateModel] for each list item. Sadly pocketbase
    // doesn't support transactional bulk operations yet. Keep an eye on
    // https://github.com/pocketbase/pocketbase/issues/48 where this will be
    // added.
    Iterable<Future<M?>> modelUpdates = models.mapIndexed((index, model) {
      return updateModel(model);
    });
    List<M?> updatedModels = await Future.wait(modelUpdates);

    return updatedModels;
  }

  /// Deletes a model from its collection on the DB.
  ///
  /// On success the future resolves to `true` otherwise `false`.
  Future<bool> deleteModel<M extends Model>(
    M deletedModel, {
    Map<String, dynamic> query = const {},
  }) async {
    assert(
      collectionRepositories.whereType<CollectionRepository<M>>().isNotEmpty,
      'The CollectionQuerier does not have the ${M.toString()} repository',
    );
    var collectionRepository =
        collectionRepositories.whereType<CollectionRepository<M>>().first;

    try {
      await collectionRepository.delete(deletedModel, query: query);
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

  CollectionRepository<M> getRepository<M extends Model>() {
    CollectionRepository<M>? repository = collectionRepositories
            .firstWhereOrNull((r) => r is CollectionRepository<M>)
        as CollectionRepository<M>?;

    if (repository == null) {
      throw Exception(
        'The CollectionQuerier does not have the ${M.toString()} repository',
      );
    }

    return repository;
  }
}

abstract class CollectionQuerierCubit<S> extends Cubit<S> {
  /// A Cubit that has a [CollectionQuerier] member.
  ///
  /// The [CollectionQuerier] is created with the given [collectionRepositories]
  /// and can be used by accessing the `querier` field.
  CollectionQuerierCubit(
    super.initialState, {
    required Iterable<CollectionRepository<Model>> collectionRepositories,
  }) : querier = CollectionQuerier(collectionRepositories) {
    _waitForRepositoryLoading();
    for (CollectionRepository<Model> repository in collectionRepositories) {
      subscribeToCollectionUpdates(repository, _notifyCollectionUpdate);
    }
  }

  final CollectionQuerier querier;

  final List<StreamSubscription> collectionUpdateSubscriptions = [];

  /// Listens to updates in the collection of [M] via the [repository].
  ///
  /// The [listener] is called with a list of [CollectionUpdateEvent]s
  /// whenever the collection behind the repository changes.
  ///
  /// When the list contains multiple events that means the event debouncer
  /// combined multiple updates that happened in a very short time.
  ///
  /// The resulting [StreamSubscription] is automatically closed when the
  /// cubit closes. This happens automatically when the cubit was created by a
  /// [BlocProvider].
  void subscribeToCollectionUpdates<M extends Model>(
    CollectionRepository<M> repository,
    void Function(List<CollectionUpdateEvent<M>> updateEvents)? listener,
  ) {
    StreamSubscription subscription = repository.updateStream.listen(listener);
    collectionUpdateSubscriptions.add(subscription);
  }

  @override
  Future<void> close() async {
    for (StreamSubscription subscription in collectionUpdateSubscriptions) {
      subscription.cancel();
    }
    return super.close();
  }

  /// Gets called when [querier] initially loads all collections and whenever
  /// any of the collections from the [querier]'s
  /// [CollectionQuerier.collectionRepositories] updates.
  ///
  /// The [collections] list is always the full list of collections, not just
  /// the updated ones.
  ///
  /// The [updateEvents] list contains the details about what was updated.
  /// It is empty on the intial load.
  ///
  /// The implementation should emit a new state here that is derived from
  /// the updates.
  void onCollectionUpdate(
    List<List<Model>> collections,
    List<CollectionUpdateEvent<Model>> updateEvents,
  );

  /// Gets called when the initial collection load fails
  void onLoadError() {
    if (state is CollectionQuerierState) {
      S failedState =
          (state as dynamic).copyWith(loadingStatus: LoadingStatus.failed);

      emit(failedState);
    }
  }

  void _waitForRepositoryLoading() async {
    Iterable<Completer> loadCompleters =
        querier.collectionRepositories.map((r) => r.loadCompleter);

    await Future.wait(loadCompleters.map((c) => c.future)).then(
      (_) => _notifyCollectionUpdate(),
      onError: (_) => onLoadError(),
    );
  }

  void _notifyCollectionUpdate([
    List<CollectionUpdateEvent<Model>>? updateEvents,
  ]) {
    List<List<Model>> collections =
        querier.collectionRepositories.map((r) => r.getList()).toList();
    onCollectionUpdate(collections, updateEvents ?? []);
  }
}

/// State class with a loading status and a list of collections.
abstract class CollectionQuerierState {
  const CollectionQuerierState();

  LoadingStatus get loadingStatus;

  List<List<Model>> get collections;

  List<M> getCollection<M extends Model>() {
    List<M>? collection =
        collections.firstWhereOrNull((c) => c is List<M>) as List<M>?;

    if (collection == null) {
      throw Exception("The state does not hold the $M collection.");
    }

    return collection;
  }

  List<M>? getCollectionOrNull<M extends Model>() {
    List<M>? collection =
        collections.firstWhereOrNull((c) => c is List<M>) as List<M>?;
    return collection;
  }

  bool hasCollection<M extends Model>() {
    return getCollectionOrNull() != null;
  }

  /// Replace the [M]-collection with the given [collection]
  void overrideCollection<M extends Model>(List<M> collection) {
    collections.removeWhere((c) => c is List<M>);
    collections.add(collection);
  }
}
