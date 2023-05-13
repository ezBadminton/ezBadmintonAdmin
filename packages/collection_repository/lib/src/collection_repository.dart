import 'package:collection_repository/collection_repository.dart';
import 'package:collection_repository/src/models/model_converter.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:pocketbase_provider/pocketbase_provider.dart';
import 'package:recase/recase.dart';

class CollectionRepository<R extends Model> {
  CollectionRepository(
      R Function(Map<String, dynamic> recordModelMap) this.modelConstructor)
      : collectionName = R.toString().snakeCase + 's';

  final _pocketBase = PocketBaseProvider().pocketBase;
  final String collectionName;
  final R Function(Map<String, dynamic> recordModelMap) modelConstructor;

  Future<List<R>> getList({ExpansionTree? expand}) async {
    String expandString = expand?.expandString ?? '';
    List<RecordModel> records = await _pocketBase
        .collection(collectionName)
        .getFullList(expand: expandString);
    List<R> models = records
        .map<R>((record) =>
            modelConstructor(ModelConverter.modelToExpandedMap(record)))
        .toList();
    return models;
  }

  Future<R> update(R updatedModel) async {
    RecordModel _ = await _pocketBase
        .collection('players')
        .update(updatedModel.id, body: updatedModel.toCollapsedJson());
    return updatedModel;
  }
}
