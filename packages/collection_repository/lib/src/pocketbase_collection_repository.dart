import 'dart:async';

import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:collection_repository/src/utils/model_converter.dart'
    as model_converter;
import 'package:pocketbase/pocketbase.dart';
import 'package:pocketbase_provider/pocketbase_provider.dart';

class PocketbaseCollectionRepository<M extends Model>
    extends CollectionRepository<M> {
  /// A repository for directly interfacing with the database.
  ///
  /// The repository handles all CRUD operations for model [M] via pocketbase.
  /// The pocketbase connection comes from a [pocketBaseProvider]. When
  /// retrieving data the [M] object is instanciated by passing the json map
  /// to the [modelConstructor]. The modelConstructor is usually `fromJson`.
  ///
  /// Example:
  /// ```dart
  /// var playerRepository = CollectionRepository(modelConstructor: Player.fromJson, pocketBaseProvider: ...)
  /// ```
  PocketbaseCollectionRepository({
    required M Function(Map<String, dynamic> recordModelMap) modelConstructor,
    required PocketBaseProvider pocketBaseProvider,
  })  : _modelConstructor = modelConstructor,
        _pocketBase = pocketBaseProvider.pocketBase,
        _collectionName = _collectionNames[M]!,
        _expandString = _defaultExpansions[M]?.expandString ?? '';

  List<M> _collection = [];

  /// The unmodifiable collection is returned by the public [getList] method
  /// It should be updated every time the [_collection] changes
  List<M> _unomdifiableCollection = List.unmodifiable([]);

  // The pocketbase SDK abstracts all the DB querying
  final PocketBase _pocketBase;
  final String _collectionName;
  final String _expandString;
  Timer? _updateDebounce;
  List<CollectionUpdateEvent<M>> _debouncedEvents = [];
  final M Function(Map<String, dynamic> recordModelMap) _modelConstructor;

  Completer<void> _loadCompleter = Completer();

  @override
  Completer<void> get loadCompleter => _loadCompleter;

  @override
  final StreamController<List<CollectionUpdateEvent<M>>>
      updateStreamController = StreamController.broadcast();

  @override
  Stream<List<CollectionUpdateEvent<M>>> get updateStream async* {
    yield* updateStreamController.stream;
  }

  static final Map<Type, ExpansionTree> _defaultExpansions = {
    Player: ExpansionTree(Player.expandedFields),
    Competition: ExpansionTree(Competition.expandedFields)
      ..expandWith(TieBreaker, TieBreaker.expandedFields)
      ..expandWith(Team, Team.expandedFields)
      ..expandWith(Player, Player.expandedFields)
      ..expandWith(MatchData, MatchData.expandedFields)
      ..expandWith(Court, Court.expandedFields),
    Team: ExpansionTree(Team.expandedFields)
      ..expandWith(Player, Player.expandedFields),
    Court: ExpansionTree(Court.expandedFields),
    MatchData: ExpansionTree(MatchData.expandedFields)
      ..expandWith(Court, Court.expandedFields),
    TieBreaker: ExpansionTree(TieBreaker.expandedFields)
      ..expandWith(Team, Team.expandedFields)
      ..expandWith(Player, Player.expandedFields),
  };

  @override
  void load() {
    if (_loadCompleter.isCompleted) {
      _loadCompleter = Completer();
    }

    _pocketBase.collection(_collectionName).unsubscribe('*');
    _fetchCollection();
    _pocketBase.collection(_collectionName).subscribe(
          '*',
          _handleCollectionUpdate,
          expand: _expandString,
        );
  }

  void _fetchCollection() async {
    List<RecordModel> records;
    try {
      records = await _pocketBase
          .collection(_collectionName)
          .getFullList(expand: _expandString);
    } on ClientException catch (e) {
      loadCompleter.completeError(e);
      return;
    }

    _collection = records
        .map<M>((record) => _modelConstructor(record.toExpandedJson()))
        .toList();
    _unomdifiableCollection = List.unmodifiable(_collection);

    loadCompleter.complete();
  }

  void _handleCollectionUpdate(RecordSubscriptionEvent realtimeEvent) {
    if (realtimeEvent.record == null) {
      return;
    }

    M? model = _modelConstructor(realtimeEvent.record!.toExpandedJson());

    CollectionUpdateEvent<M> updateEvent = switch (realtimeEvent.action) {
      "create" => CollectionUpdateEvent.create(model),
      "update" => CollectionUpdateEvent.update(model),
      "delete" => CollectionUpdateEvent.delete(model),
      _ => throw Exception("Unknown realtime event type"),
    };

    _debouncedEvents.add(updateEvent);

    if (_updateDebounce?.isActive ?? false) {
      _updateDebounce!.cancel();
    }

    _updateDebounce = Timer(const Duration(milliseconds: 25), () {
      _applyCollectionUpdates(_debouncedEvents);
      emitUpdateEvents(List.unmodifiable(_debouncedEvents));
      _debouncedEvents = [];
    });
  }

  void _applyCollectionUpdates(List<CollectionUpdateEvent<M>> events) {
    for (CollectionUpdateEvent<M> event in events) {
      switch (event.updateType) {
        case UpdateType.create:
          _collection.add(event.model);
        case UpdateType.update:
          _collection
            ..removeWhere((m) => m.id == event.model.id)
            ..add(event.model);
        case UpdateType.delete:
          _collection.removeWhere((m) => m.id == event.model.id);
      }
    }

    _unomdifiableCollection = List.unmodifiable(_collection);
  }

  @override
  M? getModel(String id) {
    if (!isLoaded) {
      throw Exception("Can't get model. The repository is not loaded yet.");
    }

    return _collection.firstWhereOrNull((model) => model.id == id);
  }

  @override
  List<M> getList({ExpansionTree? expand}) {
    if (!isLoaded) {
      throw Exception(
        "Can't get model list. The repository is not loaded yet.",
      );
    }

    return _unomdifiableCollection;
  }

  @override
  Future<M> create(
    M newModel, {
    Map<String, dynamic> query = const {},
  }) async {
    Map<String, dynamic> json = newModel.toCollapsedJson();
    json.clearMetaJsonFields();
    RecordModel created;
    try {
      created = await _pocketBase.collection(_collectionName).create(
            body: json,
            expand: _expandString,
            query: query,
          );
    } on ClientException catch (e) {
      throw CollectionQueryException('${e.statusCode}');
    }
    var createdModelFromDB = _modelConstructor(
      created.toExpandedJson(),
    );
    return createdModelFromDB;
  }

  @override
  Future<M> update(
    M updatedModel, {
    Map<String, dynamic> query = const {},
  }) async {
    Map<String, dynamic> json = updatedModel.toCollapsedJson();
    json.clearMetaJsonFields();
    RecordModel updated;
    try {
      updated = await _pocketBase.collection(_collectionName).update(
            updatedModel.id,
            body: json,
            query: query,
            expand: _expandString,
          );
    } on ClientException catch (e) {
      throw CollectionQueryException('${e.statusCode}');
    }
    var updatedModelFromDB = _modelConstructor(
      updated.toExpandedJson(),
    );
    return updatedModelFromDB;
  }

  @override
  Future<void> delete(
    M deletedModel, {
    Map<String, dynamic> query = const {},
  }) async {
    try {
      await _pocketBase.collection(_collectionName).delete(
            deletedModel.id,
            query: query,
          );
    } on ClientException catch (e) {
      throw CollectionQueryException('${e.statusCode}');
    }
  }

  void emitUpdateEvents(List<CollectionUpdateEvent<M>> events) {
    updateStreamController.add(events);
  }

  @override
  Future<void> dispose() {
    _pocketBase.collection(_collectionName).unsubscribe('*');
    return updateStreamController.close();
  }

  @override
  Future<bool> route({
    String route = "",
    String method = "GET",
    Map<String, dynamic> data = const {},
    Map<String, dynamic> query = const {},
  }) async {
    String slash = "";
    if (route.isNotEmpty && !route.startsWith('/')) {
      slash = "/";
    }

    String fullRoute = "/api/ezbadminton/${_collectionNames[M]!}$slash$route";

    try {
      await _pocketBase.send(
        fullRoute,
        method: method,
        body: data,
        query: query,
      );
    } on ClientException {
      return false;
    }

    return true;
  }
}

const Map<Type, String> _collectionNames = {
  AgeGroup: 'age_groups',
  Club: 'clubs',
  Competition: 'competitions',
  Court: 'courts',
  Gymnasium: 'gymnasiums',
  MatchSet: 'match_sets',
  MatchData: 'match_data',
  Player: 'players',
  PlayingLevel: 'playing_levels',
  Team: 'teams',
  TournamentModeSettings: 'tournament_mode_settings',
  Tournament: 'tournaments',
  TieBreaker: 'tie_breakers',
};
