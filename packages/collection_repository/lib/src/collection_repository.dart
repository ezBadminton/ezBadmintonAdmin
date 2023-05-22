import 'package:collection_repository/collection_repository.dart';
import 'package:collection_repository/src/models/model_converter.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:pocketbase_provider/pocketbase_provider.dart';
import 'package:recase/recase.dart';

class CollectionRepository<M extends Model> {
  /// A repository for interfacing the business logic with the database.
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
  CollectionRepository({
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

  /// Get the full list of model objects from the database.
  ///
  /// Relations are expanded as defined by the [expand] `ExpansionTree`.
  Future<List<M>> getList({ExpansionTree? expand}) async {
    String expandString = expand?.expandString ?? '';
    List<RecordModel> records;
    try {
      records = await _pocketBase
          .collection(_collectionName)
          .getFullList(expand: expandString);
    } on ClientException catch (e) {
      throw CollectionFetchException('$e.statusCode');
    }
    List<M> models = records
        .map<M>((record) =>
            _modelConstructor(ModelConverter.modelToExpandedMap(record)))
        .toList();
    return models;
  }

  Future<M> create(M newModel) async {
    Map<String, dynamic> json = newModel.toCollapsedJson();
    ModelConverter.clearMetaJsonFields(json);
    RecordModel created =
        await _pocketBase.collection(_collectionName).create(body: json);
    return _modelConstructor(ModelConverter.modelToMap(created));
  }

  Future<M> update(M updatedModel) async {
    Map<String, dynamic> json = updatedModel.toCollapsedJson();
    ModelConverter.clearMetaJsonFields(json);
    RecordModel updated = await _pocketBase.collection(_collectionName).update(
          updatedModel.id,
          body: json,
        );
    return _modelConstructor(ModelConverter.modelToMap(updated));
  }
}

class CollectionFetchException {
  CollectionFetchException(this.errorCode);
  final String errorCode;
}
