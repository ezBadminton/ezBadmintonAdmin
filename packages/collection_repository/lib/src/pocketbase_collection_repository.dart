import 'dart:async';
import 'dart:math';

import 'package:collection_repository/collection_repository.dart';
import 'package:collection_repository/src/models/model_converter.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:pocketbase_provider/pocketbase_provider.dart';
import 'package:recase/recase.dart';

class PocketbaseCollectionRepository<M extends Model>
    implements CollectionRepository<M> {
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
        // All model classes have a corresponding collection name
        _collectionName = M.toString().snakeCase + 's';

  // The pocketbase SDK abstracts all the DB querying
  final PocketBase _pocketBase;
  final String _collectionName;
  final M Function(Map<String, dynamic> recordModelMap) _modelConstructor;

  final StreamController<CollectionUpdateEvent<M>> _updateStreamController =
      StreamController.broadcast();

  @override
  Stream<CollectionUpdateEvent<M>> get updateStream async* {
    yield* _updateStreamController.stream;
  }

  static final Map<Type, ExpansionTree> _defaultExpansions = {
    Player: ExpansionTree(Player.expandedFields),
    Competition: ExpansionTree(Competition.expandedFields)
      ..expandWith(Team, Team.expandedFields),
    Team: ExpansionTree(Team.expandedFields),
  };

  @override
  Future<M> getModel(String id, {ExpansionTree? expand}) async {
    expand = expand ?? _defaultExpansions[M];
    String expandString = expand?.expandString ?? '';
    RecordModel record;
    try {
      record = await _pocketBase
          .collection(_collectionName)
          .getOne(id, expand: expandString);
    } on ClientException catch (e) {
      throw CollectionQueryException('$e.statusCode');
    }
    M model = _modelConstructor(ModelConverter.modelToExpandedMap(record));
    return model;
  }

  @override
  Future<List<M>> getList({ExpansionTree? expand}) async {
    expand = expand ?? _defaultExpansions[M];
    String expandString = expand?.expandString ?? '';
    List<RecordModel> records;
    try {
      records = await _pocketBase
          .collection(_collectionName)
          .getFullList(expand: expandString);
    } on ClientException catch (e) {
      throw CollectionQueryException('$e.statusCode');
    }
    List<M> models = records
        .map<M>((record) =>
            _modelConstructor(ModelConverter.modelToExpandedMap(record)))
        .toList();
    return models;
  }

  @override
  Future<M> create(M newModel, {ExpansionTree? expand}) async {
    Map<String, dynamic> json = newModel.toCollapsedJson();
    ModelConverter.clearMetaJsonFields(json);
    RecordModel created;
    try {
      created =
          await _pocketBase.collection(_collectionName).create(body: json);
    } on ClientException catch (e) {
      throw CollectionQueryException('$e.statusCode');
    }
    var createdModelFromDB = await getModel(created.id, expand: expand);
    emitUpdateEvent(
      CollectionUpdateEvent.create(createdModelFromDB),
    );
    return createdModelFromDB;
  }

  @override
  Future<M> update(M updatedModel, {ExpansionTree? expand}) async {
    Map<String, dynamic> json = updatedModel.toCollapsedJson();
    ModelConverter.clearMetaJsonFields(json);
    RecordModel updated;
    try {
      updated = await _pocketBase.collection(_collectionName).update(
            updatedModel.id,
            body: json,
          );
    } on ClientException catch (e) {
      throw CollectionQueryException('$e.statusCode');
    }
    var updatedModelFromDB = await getModel(updated.id, expand: expand);
    emitUpdateEvent(
      CollectionUpdateEvent.update(updatedModelFromDB),
    );
    return updatedModelFromDB;
  }

  @override
  Future<void> delete(M deletedModel) async {
    try {
      await _pocketBase.collection(_collectionName).delete(deletedModel.id);
    } on ClientException catch (e) {
      throw CollectionQueryException('$e.statusCode');
    }
    emitUpdateEvent(
      CollectionUpdateEvent.delete(deletedModel),
    );
  }

  void emitUpdateEvent(CollectionUpdateEvent<M> event) {
    _updateStreamController.add(event);
  }
}
