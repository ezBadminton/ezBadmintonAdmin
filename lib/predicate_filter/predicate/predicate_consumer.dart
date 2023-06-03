import 'dart:async';

import 'package:ez_badminton_admin_app/predicate_filter/predicate/filter_predicate.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/predicate_producer.dart';
import 'package:meta/meta.dart';

mixin PredicateConsumer {
  /// Intitializes this predicate consumer with a list of [producers]
  ///
  /// All [producers]' predicate streams are listened to by
  /// [onPredicateProduced].
  void initPredicateProducers(
    Iterable<PredicateProducer> producers,
  ) {
    this.producers = producers;
    producerSubscriptions = producers
        .map((p) => p.predicateStream.listen(onPredicateProduced))
        .toList();
  }

  late final Iterable<PredicateProducer> producers;
  late final Iterable<StreamSubscription> producerSubscriptions;

  P getPredicateProducer<P extends PredicateProducer>() {
    var typeProducers = producers.whereType<P>();
    assert(
      typeProducers.isNotEmpty,
      'A PredicateProducer of type ${P.toString()} could not be found',
    );
    return typeProducers.first;
  }

  @visibleForOverriding
  void onPredicateProduced(FilterPredicate predicate);

  void onPredicateRemoved(FilterPredicate predicate) {
    for (var producer in producers) {
      if (producer.producesDomain(predicate.domain)) {
        producer.produceEmptyPredicate(predicate.domain);
        return;
      }
    }
  }

  Future<void> closeProducerStreams() async {
    for (var subscription in producerSubscriptions) {
      await subscription.cancel();
    }
    for (var producer in producers) {
      producer.close();
    }
  }
}
