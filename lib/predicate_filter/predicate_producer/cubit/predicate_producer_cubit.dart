import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_filter_cubit.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate_producer/predicate_producer.dart';
import 'package:meta/meta.dart';

part 'predicate_producer_state.dart';

abstract class PredicateProducerCubit<S> extends Cubit<S> {
  PredicateProducerCubit(S initialState, {required this.producers})
      : super(initialState) {
    producerSubscriptions = producers
        .map(
          (p) => p.predicateStream.listen(onPredicateProduced),
        )
        .toList();
  }

  final Iterable<PredicateProducer> producers;
  late final Iterable<StreamSubscription> producerSubscriptions;

  P getPredicateProducer<P extends PredicateProducer>() {
    var typeProducers = producers.whereType<P>();
    if (typeProducers.isEmpty) {
      throw Exception(
          'A PredicateProducer of type ${P.toString()} could not be found');
    }
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

  @override
  Future<void> close() {
    for (var subscription in producerSubscriptions) {
      subscription.cancel();
    }
    for (var producer in producers) {
      producer.close();
    }
    return super.close();
  }
}
