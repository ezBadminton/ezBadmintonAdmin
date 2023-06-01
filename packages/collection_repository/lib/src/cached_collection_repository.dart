import 'package:collection_repository/collection_repository.dart';
import 'package:collection_repository/src/collection_repository_decorator.dart';

class CachedCollectionRepository<M extends Model>
    extends CollectionRepositoryDecorator<M> {
  CachedCollectionRepository(super.targetCollectionRepository);

  List<M> _cachedCollection = [];
  bool _collectionCached = false;

  @override
  Stream<CollectionUpdateEvent<M>> get updateStream =>
      targetCollectionRepository.updateStream;

  @override
  Future<M> getModel(String id, {ExpansionTree? expand}) async {
    var cached = _collectionCached
        ? _cachedCollection.singleWhere(
            (model) => model.id == id,
            orElse: (null),
          )
        : null;
    if (cached != null) {
      return cached;
    } else {
      _collectionCached = false;
      return await targetCollectionRepository.getModel(id, expand: expand);
    }
  }

  @override
  Future<List<M>> getList({ExpansionTree? expand}) async {
    if (_collectionCached) {
      return List.of(_cachedCollection);
    } else {
      var collection = await targetCollectionRepository.getList(expand: expand);
      _cachedCollection = List.of(collection);
      _collectionCached = true;
      return collection;
    }
  }

  @override
  Future<M> create(M newModel, {ExpansionTree? expand}) async {
    var createdModelFromDB = await targetCollectionRepository.create(
      newModel,
      expand: expand,
    );
    _cachedCollection.add(createdModelFromDB);
    return createdModelFromDB;
  }

  @override
  Future<M> update(M updatedModel, {ExpansionTree? expand}) async {
    var updatedModelFromDB = await targetCollectionRepository.update(
      updatedModel,
      expand: expand,
    );
    _cachedCollection
      ..removeWhere((m) => m.id == updatedModelFromDB.id)
      ..add(updatedModelFromDB);
    return updatedModelFromDB;
  }

  @override
  Future<void> delete(M deletedModel) async {
    await targetCollectionRepository.delete(deletedModel);
    _cachedCollection.removeWhere((m) => m.id == deletedModel.id);
  }

  @override
  Future<void> dispose() {
    return targetCollectionRepository.dispose();
  }
}
