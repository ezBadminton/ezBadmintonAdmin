import 'package:collection_repository/collection_repository.dart';

abstract class CollectionRepositoryDecorator<M extends Model>
    extends CollectionRepository<M> {
  CollectionRepositoryDecorator(this.targetCollectionRepository);

  final CollectionRepository<M> targetCollectionRepository;
}
