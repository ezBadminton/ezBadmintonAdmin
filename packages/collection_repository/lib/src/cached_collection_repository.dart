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
  Future<M> create(M newModel) async {
    var createdModelFromDB = await targetCollectionRepository.create(newModel);
    _collectionCached = false;
    return createdModelFromDB;
  }

  @override
  Future<M> update(M updatedModel) async {
    var updatedModelFromDB =
        await targetCollectionRepository.update(updatedModel);
    _collectionCached = false;
    return updatedModelFromDB;
  }

  @override
  Future<void> delete(M deletedModel) async {
    await targetCollectionRepository.delete(deletedModel);
    _collectionCached = false;
  }
}
