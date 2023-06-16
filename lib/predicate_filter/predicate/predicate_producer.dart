import 'dart:async';

import 'package:ez_badminton_admin_app/predicate_filter/predicate/filter_predicate.dart';
import 'package:meta/meta.dart';

/// A class producing [FilterPredicate]s and emitting them on a
/// single subscriber stream
abstract class PredicateProducer {
  Stream<FilterPredicate> get predicateStream =>
      predicateStreamController.stream;

  @protected
  final predicateStreamController = StreamController<FilterPredicate>();

  Future<void> close() => predicateStreamController.close();

  void produceEmptyPredicate(dynamic predicateDomain);

  bool producesDomain(dynamic predicateDomain);
}
