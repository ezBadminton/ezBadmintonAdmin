import 'package:collection_repository/collection_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef FetcherFunction<M extends Model> = Future<List<M>?> Function();

typedef StateUpdater<M extends Model> = void Function(List<M>);

abstract class CollectionQuerierState {
  const CollectionQuerierState();
  copyWithCollection({
    required Type modelType,
    required List<Model> collection,
  });
  List<M> getCollection<M extends Model>();
}

abstract class CollectionQuerierCubit<State extends CollectionQuerierState>
    extends Cubit<State> {
  CollectionQuerierCubit(super.initialState);

  static final Map<Type, ExpansionTree> _defaultExpansions = {
    Player: ExpansionTree(Player.expandedFields),
    Competition: ExpansionTree(Competition.expandedFields)
      ..expandWith(Team, Team.expandedFields),
    Team: ExpansionTree(Team.expandedFields),
  };

  abstract final Iterable<CollectionRepository<Model>> collectionRepositories;

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

  Future<List<List<Model>?>> fetchCollections(
      Iterable<FetcherFunction> fetchers) async {
    var fetchResults =
        await Future.wait([for (var fetcher in fetchers) fetcher()]);
    return fetchResults;
  }

  CollectionFetcher collectionFetcher<M extends Model>({
    ExpansionTree? expand,
  }) =>
      CollectionFetcher<M>(
          fetcherFunction: () => fetchCollection<M>(expand: expand));

  void fetchCollectionsAndUpdateState(
    Iterable<CollectionFetcher> fetchers, {
    void Function(State updatedState)? onSuccess,
    void Function()? onFailure,
  }) async {
    var fetchResults =
        await fetchCollections(fetchers.map((f) => f.fetcherFunction));
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

  Future<M?> createModel<M extends Model>(M newModel) async {
    var collectionRepository =
        collectionRepositories.whereType<CollectionRepository<M>>().first;

    try {
      return await collectionRepository.create(newModel);
    } on CollectionQueryException {
      return null;
    }
  }

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

class CollectionFetcher<M extends Model> {
  CollectionFetcher({required this.fetcherFunction});
  final FetcherFunction fetcherFunction;
  Type get modelType => M;
}
