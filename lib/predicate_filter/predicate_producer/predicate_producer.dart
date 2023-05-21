import 'dart:async';

import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_filter_cubit.dart';
import 'package:meta/meta.dart';

abstract class PredicateProducer {
  Stream<FilterPredicate> get predicateStream async* {
    yield* predicateStreamController.stream;
  }

  @protected
  final predicateStreamController = StreamController<FilterPredicate>();

  void close() => predicateStreamController.close();

  void produceEmptyPredicate(dynamic predicateDomain);

  bool producesDomain(dynamic predicateDomain);
}
