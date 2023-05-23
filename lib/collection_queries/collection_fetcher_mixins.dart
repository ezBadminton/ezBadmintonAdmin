import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';

typedef FetcherFunction<M extends Model> = Future<List<M>?> Function({
  ExpansionTree? expand,
});

typedef StateUpdater<M extends Model> = void Function(List<M>);

mixin PlayerFetch on CollectionQuerier {
  Future<List<Player>?> fetchPlayerList({
    ExpansionTree? expand,
  }) async {
    try {
      return await collectionRepositories
          .whereType<CollectionRepository<Player>>()
          .first
          .getList(
            expand: expand ?? ExpansionTree(Player.expandedFields),
          );
    } on CollectionFetchException {
      return null;
    }
  }
}

mixin CompetitionFetch on CollectionQuerier {
  Future<List<Competition>?> fetchCompetitionList({
    ExpansionTree? expand,
  }) async {
    try {
      return await collectionRepositories
          .whereType<CollectionRepository<Competition>>()
          .first
          .getList(
            expand: expand ?? ExpansionTree(Competition.expandedFields)
              ..expandWith(Team, Team.expandedFields),
          );
    } on CollectionFetchException {
      return null;
    }
  }
}

mixin PlayingLevelFetch on CollectionQuerier {
  Future<List<PlayingLevel>?> fetchPlayingLevelList({
    ExpansionTree? expand,
  }) async {
    try {
      return await collectionRepositories
          .whereType<CollectionRepository<PlayingLevel>>()
          .first
          .getList();
    } on CollectionFetchException {
      return null;
    }
  }
}

mixin ClubFetch on CollectionQuerier {
  Future<List<Club>?> fetchClubList({
    ExpansionTree? expand,
  }) async {
    try {
      return await collectionRepositories
          .whereType<CollectionRepository<Club>>()
          .first
          .getList();
    } on CollectionFetchException {
      return null;
    }
  }
}

mixin TeamFetch on CollectionQuerier {
  Future<List<Team>?> fetchTeamList({
    ExpansionTree? expand,
  }) async {
    try {
      return await collectionRepositories
          .whereType<CollectionRepository<Team>>()
          .first
          .getList(
            expand: expand ?? ExpansionTree(Team.expandedFields),
          );
    } on CollectionFetchException {
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
