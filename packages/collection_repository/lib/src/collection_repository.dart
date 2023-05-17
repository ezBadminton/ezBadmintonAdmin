import 'package:collection_repository/collection_repository.dart';
import 'package:collection_repository/src/models/model_converter.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:pocketbase_provider/pocketbase_provider.dart';
import 'package:recase/recase.dart';

class CollectionRepository<R extends Model> {
  /// A repository for interfacing the business logic with the database.
  ///
  /// The repository handles all CRUD operations for one model via pocketbase.
  /// The pocketbase connection comes from a [pocketBaseProvider]. When
  /// retrieving data the model object is instanciated by passing the json map
  /// to the [modelConstructor]. The modelConstructor is usually `fromJson`.
  ///
  /// Example: `var playerRepository = CollectionRepository(modelConstructor: Player.fromJson, pocketBaseProvider: ...)`
  CollectionRepository({
    required R Function(Map<String, dynamic> recordModelMap) modelConstructor,
    required PocketBaseProvider pocketBaseProvider,
  })  : _modelConstructor = modelConstructor,
        _pocketBaseProvider = pocketBaseProvider,
        _pocketBase = pocketBaseProvider.pocketBase,
        // All model classes have a corresponding collection name
        _collectionName = R.toString().snakeCase + 's';

  // The pocketbase SDK abstracts all the DB querying
  final PocketBaseProvider _pocketBaseProvider;
  final PocketBase _pocketBase;
  final String _collectionName;
  final R Function(Map<String, dynamic> recordModelMap) _modelConstructor;

  /// Get the full list of model objects from the database.
  ///
  /// Relations are expanded as defined by the [expand] `ExpansionTree`.
  Future<List<R>> getList({ExpansionTree? expand}) async {
    String expandString = expand?.expandString ?? '';
    List<RecordModel> records = await _pocketBase
        .collection(_collectionName)
        .getFullList(expand: expandString);
    List<R> models = records
        .map<R>((record) =>
            _modelConstructor(ModelConverter.modelToExpandedMap(record)))
        .toList();
    return models;
  }

  Future<R?> create(R newModel) async {
    Map<String, dynamic> json = newModel.toCollapsedJson();
    _clearJsonForCreate(json);
    RecordModel created =
        await _pocketBase.collection(_collectionName).create(body: json);
    return _modelConstructor(ModelConverter.modelToMap(created));
  }

  Future<R> update(R updatedModel) async {
    RecordModel _ = await _pocketBase
        .collection('players')
        .update(updatedModel.id, body: updatedModel.toCollapsedJson());
    return updatedModel;
  }

  /// Remove fields that the database sets before sending a new object
  /// for create or update.
  static void _clearJsonForCreate(Map<String, dynamic> json) {
    for (var key in ['id', 'created', 'updated']) {
      if (json.containsKey(key)) {
        json.remove(key);
      }
    }
  }
}
