import 'package:collection_repository/collection_repository.dart';
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

  static final Map<Type, ExpansionTree> _defaultExpansions = {
    Player: ExpansionTree(Player.expandedFields),
    Competition: ExpansionTree(Competition.expandedFields)
      ..expandWith(Team, Team.expandedFields),
    Team: ExpansionTree(Team.expandedFields),
  };

  /// Fetches the full collection of data objects of the model type [M]
  ///
  /// The Future resolves to null if the collection db can't be reached.
  /// Use an [ExpansionTree] as the [expand] parameter to also fetch the related
  /// models of [M]. Some [Model]s have default expansions defined.
  Future<List<M>?> fetchCollection<M extends Model>({
    ExpansionTree? expand,
  }) async {
    var collectionRepository =
        collectionRepositories.whereType<CollectionRepository<M>>().first;
    try {
      return await collectionRepository.getList(
        expand: expand ?? _defaultExpansions[M],
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
      Iterable<FetcherFunction> fetcherFunctions) async {
    var fetchResults =
        await Future.wait([for (var fetcher in fetcherFunctions) fetcher()]);
    return fetchResults;
  }

  /// Puts a newly created model into its collection on the DB.
  ///
  /// On success the Future resolves to the [Model] of type [M] with its
  /// `id`, `created` and `updated` fields set.
  /// Otherwise null if the collection db can't be reached.
  Future<M?> createModel<M extends Model>(M newModel) async {
    var collectionRepository =
        collectionRepositories.whereType<CollectionRepository<M>>().first;

    try {
      return await collectionRepository.create(newModel);
    } on CollectionQueryException {
      return null;
    }
  }

  /// Updates a model in its collection on the DB.
  ///
  /// On success the Future resolves to the [Model] of type [M] with its
  /// new `updated` timestamp.
  /// Otherwise null if the collection db can't be reached.
  Future<M?> updateModel<M extends Model>(M updatedModel) async {
    var collectionRepository =
        collectionRepositories.whereType<CollectionRepository<M>>().first;

    try {
      return await collectionRepository.update(updatedModel);
    } on CollectionQueryException {
      return null;
    }
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
}

class CollectionFetcherCubit<State extends CollectionFetcherState>
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
      if (onFailure != null) {
        onFailure();
      }
    } else {
      var updatedState = state;
      int i = 0;
      for (var collection in fetchResults) {
        updatedState = updatedState.copyWithCollection(
          modelType: fetchers.elementAt(i++).modelType,
          collection: collection!,
        );
      }
      if (onSuccess != null) {
        onSuccess(updatedState);
      }
    }
  }
}

abstract class CollectionHolder {
  abstract final Map<Type, List<Model>> collections;
}

mixin CollectionGetter implements CollectionHolder {
  List<M> getCollection<M extends Model>() {
    return collections[M] as List<M>;
  }
}

abstract class CollectionFetcherState {
  const CollectionFetcherState();
  copyWithCollection({
    required Type modelType,
    required List<Model> collection,
  });
  List<M> getCollection<M extends Model>();
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
