import 'dart:async';

import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/filter_predicate.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/predicate_consumer.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/predicate_producer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPredicateProducer extends Mock implements PredicateProducer {}

class MockPredicateProducer2 extends Mock implements PredicateProducer {}

class TestPredicateConsumer with PredicateConsumer {
  TestPredicateConsumer({
    required Iterable<PredicateProducer> producers,
  }) {
    initPredicateProducers(producers);
  }

  FilterPredicate? lastConsumed;

  @override
  void onPredicateProduced(FilterPredicate predicate) {
    lastConsumed = predicate;
  }
}

class PredicateFunction extends CustomMatcher {
  PredicateFunction(matcher)
      : super(
          'FilterPredicate with a predicate function that is',
          'Predicate function',
          matcher,
        );
  @override
  featureValueOf(actual) => (actual as FilterPredicate).function;
}

class PredicateDomain extends CustomMatcher {
  PredicateDomain(matcher)
      : super(
          'FilterPredicate with a domain of',
          'Predicate domain',
          matcher,
        );
  @override
  featureValueOf(actual) => (actual as FilterPredicate).domain;
}

void main() {
  late TestPredicateConsumer sut;
  late List<StreamController<FilterPredicate>> producerStreamControllers;
  late Iterable<PredicateProducer> producers;

  setUp(() {
    producerStreamControllers =
        List<StreamController<FilterPredicate>>.generate(
            2, (_) => StreamController());
    producers =
        ['domain1', 'domain2'].mapIndexed<PredicateProducer>((index, domain) {
      var producer = MockPredicateProducer();
      var controller = producerStreamControllers[index];
      var producedEmptyPredicate = FilterPredicate(
        null,
        Player,
        'name',
        domain,
      );
      when(() => producer.predicateStream).thenAnswer((_) => controller.stream);
      when(() => producer.produceEmptyPredicate(any())).thenAnswer((_) {
        controller.add(producedEmptyPredicate);
      });
      when(() => producer.producesDomain(any())).thenAnswer(
          (invocation) => invocation.positionalArguments[0] == domain);
      when(() => producer.close()).thenAnswer((invocation) {
        return controller.close();
      });

      return producer;
    });
    sut = TestPredicateConsumer(producers: producers);
  });

  test('all given predicate producers are subscribed to', () {
    expect(sut.producerSubscriptions, hasLength(producers.length));
  });

  test('producers can be retrieved by type', () {
    expect(
      sut.getPredicateProducer<MockPredicateProducer>(),
      isA<MockPredicateProducer>(),
    );
    expect(
      () => sut.getPredicateProducer<MockPredicateProducer2>(),
      throwsAssertionError,
    );
  });

  test(
    'consumes the FilterPredicate when one of the producers produces one',
    () async {
      producerStreamControllers[0].add(FilterPredicate(
        (o) => false,
        Player,
        'name',
        'domain1',
      ));
      await Future.delayed(Duration.zero);
      expect(sut.lastConsumed, PredicateDomain('domain1'));
    },
  );

  test(
    """consumes an empty FilterPredicate of correct domain when
    onPredicateRemoved is called""",
    () async {
      sut.onPredicateRemoved(FilterPredicate(
        (o) => false,
        Player,
        'name',
        'domain1',
      ));
      await Future.delayed(Duration.zero);
      expect(
        sut.lastConsumed,
        allOf(
          PredicateDomain('domain1'),
          PredicateFunction(isNull),
        ),
      );

      sut.onPredicateRemoved(FilterPredicate(
        (o) => false,
        Player,
        'name',
        'domain2',
      ));
      await Future.delayed(Duration.zero);
      expect(
        sut.lastConsumed,
        allOf(
          PredicateDomain('domain2'),
          PredicateFunction(isNull),
        ),
      );

      sut.onPredicateRemoved(FilterPredicate(
        (o) => false,
        Player,
        'name',
        'non existent domain',
      ));
      await Future.delayed(Duration.zero);
      expect(
        sut.lastConsumed,
        allOf(
          PredicateDomain('domain2'),
          PredicateFunction(isNull),
        ),
      );
    },
  );

  test(
    'closes all producer streams after closeProducerStreams()',
    () async {
      await sut.closeProducerStreams();
      for (var controller in producerStreamControllers) {
        expect(controller.isClosed, true);
      }
    },
  );
}
