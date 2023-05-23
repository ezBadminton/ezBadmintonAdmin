import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef FetcherFunction<M extends Model> = Future<List<M>?> Function({
  ExpansionTree? expand,
});

typedef StateUpdater<M extends Model> = void Function(List<M>);

Map<Type, ExpansionTree> _defaultExpansions = {
  Player: ExpansionTree(Player.expandedFields),
  Competition: ExpansionTree(Competition.expandedFields)
    ..expandWith(Team, Team.expandedFields),
  Team: ExpansionTree(Team.expandedFields),
};

mixin CollectionFetch on CollectionQuerier {
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
}

mixin FetcherBloc {
  Future<List<List<Model>?>> fetchCollections(
      Iterable<FetcherFunction> fetchers) async {
    var fetchResults =
        await Future.wait([for (var fetcher in fetchers) fetcher()]);
    return fetchResults;
  }

  void fetchCollectionsAndUpdateState(
      Map<FetcherFunction, StateUpdater> updaters,
      {void Function()? onSuccess,
      void Function()? onFailure}) async {
    var fetchResults = await fetchCollections(updaters.keys);
    if (fetchResults.contains(null)) {
      if (onFailure != null) {
        onFailure();
      }
    } else {
      int i = 0;
      for (var updater in updaters.values) {
        updater(fetchResults[i++]!);
      }
      if (onSuccess != null) {
        onSuccess();
      }
    }
  }
}
