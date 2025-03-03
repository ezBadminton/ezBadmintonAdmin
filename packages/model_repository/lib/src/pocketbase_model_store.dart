import 'dart:async';

import 'package:collection/collection.dart';
import 'package:model_repository/model_repository.dart';
import 'package:pocketbase/pocketbase.dart';

class PocketbaseModelStore<M extends Model> extends ModelStore<M> {
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
  PocketbaseModelStore({
    required this.repository,
    required M Function(Map<String, dynamic> recordModelMap) modelConstructor,
    required PocketBase pocketBase,
  })  : _modelConstructor = modelConstructor,
        _pocketBase = pocketBase,
        _collectionName = _collectionNames[M]!;

  @override
  final ModelRepository repository;

  List<M> _collection = [];

  /// The unmodifiable collection is returned by the public [getList] method
  /// It should be updated every time the [_collection] changes
  List<M> _unomdifiableCollection = List.unmodifiable([]);

  // The pocketbase SDK abstracts all the DB querying
  final PocketBase _pocketBase;
  final String _collectionName;
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

  @override
  Future<void> load() async {
    if (_loadCompleter.isCompleted) {
      _loadCompleter = Completer();
    }

    _pocketBase.collection(_collectionName).unsubscribe('*');
    await _fetchCollection();
    _pocketBase.collection(_collectionName).subscribe(
          '*',
          _handleCollectionUpdate,
        );
  }

  Future<void> _fetchCollection() async {
    List<RecordModel> records;
    try {
      records = await _pocketBase.collection(_collectionName).getFullList();
    } on ClientException catch (e) {
      loadCompleter.completeError(e);
      return;
    }

    _collection =
        records.map<M>((record) => _modelConstructor(record.toJson())).toList();
    _unomdifiableCollection = List.unmodifiable(_collection);

    loadCompleter.complete();
  }

  void _handleCollectionUpdate(RecordSubscriptionEvent realtimeEvent) {
    if (realtimeEvent.record == null) {
      return;
    }

    M model = _modelConstructor(realtimeEvent.record!.toJson());

    CollectionUpdateEvent<M> updateEvent = switch (realtimeEvent.action) {
      "create" => CollectionUpdateEvent.create(model),
      "update" => CollectionUpdateEvent.update(model),
      "delete" => CollectionUpdateEvent.delete(model),
      _ => throw Exception("Unknown realtime event type"),
    };

    _applyCollectionUpdate(updateEvent);
    emitUpdateEvents([updateEvent]);
  }

  void _applyCollectionUpdate(CollectionUpdateEvent<M> event) {
    var model = event.model;
    switch (event.updateType) {
      case UpdateType.create:
        _collection.add(model);
        ModelRepository.instance.created(model);
      case UpdateType.update:
        _collection
          ..removeWhere((m) => m.id == model.id)
          ..add(model);
        ModelRepository.instance.updated(model);
      case UpdateType.delete:
        _collection.removeWhere((m) => m.id == model.id);
        ModelRepository.instance.deleted(model);
    }

    _unomdifiableCollection = List.unmodifiable(_collection);
  }

  @override
  M? getModel(String id) {
    if (!isLoaded) {
      throw Exception("Can't get model. The store is not loaded yet.");
    }

    return _collection.firstWhereOrNull((model) => model.id == id);
  }

  @override
  List<M> getList() {
    if (!isLoaded) {
      throw Exception(
        "Can't get model list. The store is not loaded yet.",
      );
    }

    return _unomdifiableCollection;
  }

  @override
  Future<M> create(
    M newModel, {
    Map<String, dynamic> query = const {},
    Map<String, dynamic> body = const {},
  }) async {
    Map<String, dynamic> json = newModel.toJson();
    json.addAll(body);
    // json.clearMetaJsonFields();
    RecordModel created;
    try {
      created = await _pocketBase.collection(_collectionName).create(
            body: json,
            query: query,
          );
    } on ClientException catch (e) {
      throw CollectionQueryException('${e.statusCode}');
    }
    var createdModelFromDB = _modelConstructor(
      created.toJson(),
    );
    return createdModelFromDB;
  }

  @override
  Future<M> update(
    M updatedModel, {
    Map<String, dynamic> query = const {},
  }) async {
    Map<String, dynamic> json = updatedModel.toJson();
    // json.clearMetaJsonFields();
    RecordModel updated;
    try {
      updated = await _pocketBase.collection(_collectionName).update(
            updatedModel.id,
            body: json,
            query: query,
          );
    } on ClientException catch (e) {
      throw CollectionQueryException('${e.statusCode}');
    }
    var updatedModelFromDB = _modelConstructor(
      updated.toJson(),
    );
    return updatedModelFromDB;
  }

  @override
  Future<List<bool>> updateTransaction(List<M> updatedModels) async {
    var transaction = _pocketBase.createBatch();
    for (M model in updatedModels) {
      transaction.collection(_collectionName).update(
            model.id,
            body: model.toJson(),
          );
    }
    try {
      var results = await transaction.send();
      return results.map((r) => r.status == 200).toList();
    } on ClientException catch (e) {
      throw CollectionQueryException('${e.statusCode}');
    }
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

  @override
  Future<void> deleteTransaction(List<M> deletedModels) async {
    var transaction = _pocketBase.createBatch();
    for (M model in deletedModels) {
      transaction.collection(_collectionName).delete(model.id);
    }
    try {
      await transaction.send();
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
  Registration: 'registrations',
  Schedule: 'schedule',
  ScheduledRound: 'scheduled_rounds',
  ScheduledMatch: 'scheduled_matches',
};
