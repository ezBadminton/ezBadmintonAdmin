import 'dart:async';

import 'package:collection/collection.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';

typedef FetcherFunction<M extends Model> = FutureOr<List<M>> Function();

class CollectionQuerier {
  /// A class that has functions to fetch and update collections from db.
  ///
  /// The collections are accessed via [ModelStore] objects given
  /// by [modelStores]. Each store object is granting access to
  /// a collection of one [Model].
  ///
  /// Example:
  /// ```dart
  /// ModelStore<Player> playerStore = ...; // Usually injected by a repository provider
  /// ModelStore<Team> teamStore = ...;
  /// var querier = CollectionQuerier(
  ///   [
  ///     playerStore,
  ///     teamStore,
  ///   ],
  /// );
  ///
  /// // Fetch Player collection in some async function:
  /// List<Player>? players = await querier.fetchCollection<Player>();
  /// ```
  ///
  /// The `querier` now has the ability to fetch [Player] and [Team]
  /// collections. Beware trying to do collection operations
  /// on Models that the [CollectionQuerier] does not have the store
  /// of. This will lead to exceptions.
  CollectionQuerier(this.modelStores, {this.pb});

  final Iterable<ModelStore<Model>> modelStores;

  final PocketBase? pb;

  /// Gets one model from the [M]-collection by [id].
  ///
  /// Returns `null` if that [id] doesn't exist
  M? getModel<M extends Model>(String id) {
    var collectionRepository = getStore<M>();

    return collectionRepository.getModel(id);
  }

  /// Gets the full [M]-collection
  List<M> getCollection<M extends Model>() {
    var store = getStore<M>();
    return store.getList();
  }

  /// Puts a newly created model into its collection on the DB.
  ///
  /// On success the Future resolves to the [Model] of type [M] with its
  /// `id`, `created` and `updated` fields set.
  /// Otherwise null if the collection db can't be reached.
  Future<M?> createModel<M extends Model>(
    M newModel, {
    Map<String, dynamic> query = const {},
    Map<String, dynamic> body = const {},
  }) async {
    assert(newModel.id.isEmpty);
    var store = getStore<M>();
    try {
      return await store.create(newModel, query: query, body: body);
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
    var store = getStore<M>();

    try {
      return await store.update(updatedModel, query: query);
    } on CollectionQueryException {
      return null;
    }
  }

  Future<List<bool>> updateModels<M extends Model>(List<M> models) async {
    var store = getStore<M>();

    try {
      return store.updateTransaction(models);
    } catch (e) {
      return List<bool>.generate(models.length, (_) => false);
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

  /// Deletes a model from its collection on the DB.
  ///
  /// On success the future resolves to `true` otherwise `false`.
  Future<bool> deleteModel<M extends Model>(
    M deletedModel, {
    Map<String, dynamic> query = const {},
  }) async {
    var store = getStore<M>();

    try {
      await store.delete(deletedModel, query: query);
      return true;
    } on CollectionQueryException {
      return false;
    }
  }

  Future<bool> deleteModels<M extends Model>(List<M> models) async {
    var store = getStore<M>();

    try {
      await store.deleteTransaction(models);
      return true;
    } on CollectionQueryException {
      return false;
    }
  }

  ModelStore<M> getStore<M extends Model>() {
    ModelStore<M>? store = modelStores
        .firstWhereOrNull((r) => r is ModelStore<M>) as ModelStore<M>?;

    if (store == null) {
      throw Exception(
        'The CollectionQuerier does not have the ${M.toString()} store',
      );
    }

    return store;
  }
}

abstract class CollectionQuerierCubit<S> extends Cubit<S> {
  /// A Cubit that has a [CollectionQuerier] member.
  ///
  /// The [CollectionQuerier] is created with the given [modelStores]
  /// and can be used by accessing the `querier` field.
  CollectionQuerierCubit(
    super.initialState, {
    required Iterable<ModelStore<Model>> modelStores,
    PocketBase? pocketBase,
  }) : querier = CollectionQuerier(modelStores, pb: pocketBase) {
    _waitForRepositoryLoading();
    for (ModelStore<Model> store in modelStores) {
      subscribeToCollectionUpdates(store, _notifyCollectionUpdate);
    }
  }

  final CollectionQuerier querier;

  final List<StreamSubscription> collectionUpdateSubscriptions = [];

  /// Listens to updates in the collection of [M] via the [store].
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
    ModelStore<M> store,
    void Function(List<CollectionUpdateEvent<M>> updateEvents)? listener,
  ) {
    StreamSubscription subscription = store.updateStream.listen(listener);
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
  /// [CollectionQuerier.modelStores] updates.
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

  void _waitForRepositoryLoading() {
    ModelRepository.instance.loadCompleter.future.then(
      (_) => _notifyCollectionUpdate(),
      onError: (_) => onLoadError(),
    );
  }

  void _notifyCollectionUpdate([
    List<CollectionUpdateEvent<Model>>? updateEvents,
  ]) {
    List<List<Model>> collections =
        querier.modelStores.map((r) => r.getList()).toList();
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
