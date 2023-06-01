import 'package:collection_repository/collection_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class HasType extends CustomMatcher {
  HasType(matcher)
      : super(
          'CollectionUpdateEvent that has type',
          'update type',
          matcher,
        );
  @override
  Object? featureValueOf(dynamic actual) =>
      (actual as CollectionUpdateEvent).updateType;
}

class HasModel extends CustomMatcher {
  HasModel(matcher)
      : super(
          'CollectionUpdateEvent that has model',
          'updated model',
          matcher,
        );
  @override
  Object? featureValueOf(dynamic actual) =>
      (actual as CollectionUpdateEvent).model;
}

class WithId extends CustomMatcher {
  WithId(matcher)
      : super(
          'model with an id of',
          'model id',
          matcher,
        );
  @override
  Object? featureValueOf(dynamic actual) => (actual as Model).id;
}
