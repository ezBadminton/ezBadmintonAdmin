import 'dart:async';

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
        _collectionName = _collectionNames[M]!;

  // The pocketbase SDK abstracts all the DB querying
  final PocketBase _pocketBase;
  final String _collectionName;
  final M Function(Map<String, dynamic> recordModelMap) _modelConstructor;

  @override
  final StreamController<CollectionUpdateEvent<M>> updateStreamController =
      StreamController.broadcast();

  @override
  final StreamController<void> updateNotificationStreamController =
      StreamController.broadcast();

  @override
  Stream<CollectionUpdateEvent<M>> get updateStream async* {
    yield* updateStreamController.stream;
  }

  @override
  Stream<void> get updateNotificationStream async* {
    yield* updateNotificationStreamController.stream;
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
  Future<M> getModel(String id, {ExpansionTree? expand}) async {
    var expandString = expandStringFromExpansionTree(expand);
    RecordModel record;
    try {
      record = await _pocketBase
          .collection(_collectionName)
          .getOne(id, expand: expandString);
    } on ClientException catch (e) {
      throw CollectionQueryException('${e.statusCode}');
    }
    M model = _modelConstructor(record.toExpandedJson());
    return model;
  }

  @override
  Future<List<M>> getList({ExpansionTree? expand}) async {
    var expandString = expandStringFromExpansionTree(expand);
    List<RecordModel> records;
    try {
      records = await _pocketBase
          .collection(_collectionName)
          .getFullList(expand: expandString);
    } on ClientException catch (e) {
      throw CollectionQueryException('${e.statusCode}');
    }
    List<M> models = records
        .map<M>((record) => _modelConstructor(record.toExpandedJson()))
        .toList();
    return models;
  }

  @override
  Future<M> create(M newModel, {ExpansionTree? expand}) async {
    var expandString = expandStringFromExpansionTree(expand);
    Map<String, dynamic> json = newModel.toCollapsedJson();
    json.clearMetaJsonFields();
    RecordModel created;
    try {
      created = await _pocketBase.collection(_collectionName).create(
            body: json,
            expand: expandString,
          );
    } on ClientException catch (e) {
      throw CollectionQueryException('${e.statusCode}');
    }
    var createdModelFromDB = _modelConstructor(
      created.toExpandedJson(),
    );
    emitUpdateEvent(
      CollectionUpdateEvent.create(createdModelFromDB),
    );
    return createdModelFromDB;
  }

  @override
  Future<M> update(
    M updatedModel, {
    ExpansionTree? expand,
    bool isMulti = false,
    bool isFinalMulti = false,
  }) async {
    var expandString = expandStringFromExpansionTree(expand);
    Map<String, dynamic> json = updatedModel.toCollapsedJson();
    json.clearMetaJsonFields();
    RecordModel updated;
    try {
      updated = await _pocketBase.collection(_collectionName).update(
            updatedModel.id,
            body: json,
            expand: expandString,
          );
    } on ClientException catch (e) {
      throw CollectionQueryException('${e.statusCode}');
    }
    var updatedModelFromDB = _modelConstructor(
      updated.toExpandedJson(),
    );
    emitUpdateEvent(CollectionUpdateEvent.update(
      updatedModelFromDB,
      isMulti: isMulti,
      isFinalMulti: isFinalMulti,
    ));
    if (!isMulti || isFinalMulti) {
      emitUpdateNotification();
    }
    return updatedModelFromDB;
  }

  @override
  Future<void> delete(M deletedModel) async {
    try {
      await _pocketBase.collection(_collectionName).delete(deletedModel.id);
    } on ClientException catch (e) {
      throw CollectionQueryException('${e.statusCode}');
    }
    emitUpdateEvent(
      CollectionUpdateEvent.delete(deletedModel),
    );
  }

  void emitUpdateEvent(CollectionUpdateEvent<M> event) {
    updateStreamController.add(event);
  }

  String expandStringFromExpansionTree(ExpansionTree? expand) {
    expand = expand ?? _defaultExpansions[M];
    return expand?.expandString ?? '';
  }

  @override
  Future<void> dispose() {
    return updateStreamController.close();
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
