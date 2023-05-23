import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';

mixin CollectionUpdater on CollectionQuerier {
  Future<M?> createModel<M extends Model>(M newModel) async {
    var collectionRepository =
        collectionRepositories.whereType<CollectionRepository<M>>().first;

    try {
      return await collectionRepository.create(newModel);
    } on CollectionQueryException {
      return null;
    }
  }

  Future<M?> updateModel<M extends Model>(M updatedModel) async {
    var collectionRepository =
        collectionRepositories.whereType<CollectionRepository<M>>().first;

    try {
      return await collectionRepository.update(updatedModel);
    } on CollectionQueryException {
      return null;
    }
  }
}
