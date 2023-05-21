import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_filter_cubit.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate_producer/cubit/predicate_producer_cubit.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate_producer/predicate_producer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPredicateProducer extends Mock implements PredicateProducer {}

class MockPredicateProducer2 extends Mock implements PredicateProducer {}

class TestPredicateProducerCubit
    extends PredicateProducerCubit<FilterPredicate?> {
  TestPredicateProducerCubit(
    super.initialState, {
    required super.producers,
  });

  @override
  void onPredicateProduced(FilterPredicate predicate) {
    emit(predicate);
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
  late TestPredicateProducerCubit sut;
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
        controller.close();
      });

      return producer;
    });
    sut = TestPredicateProducerCubit(null, producers: producers);
  });

  test('all given predicate producers are subscribed to', () {
    expect(sut.producerSubscriptions, hasLength(producers.length));
  });

  test('producers can be retrieved by type', () {
    expect(
      sut.getPredicateProducer<MockPredicateProducer>(),
      isA<MockPredicateProducer>(),
    );
    Exception? exception;
    try {
      sut.getPredicateProducer<MockPredicateProducer2>();
    } on Exception catch (e) {
      exception = e;
    }
    expect(exception, isNotNull);
  });

  blocTest<TestPredicateProducerCubit, FilterPredicate?>(
    'emits a FilterPredicate when one of the producers produces one',
    build: () => sut,
    act: (_) => producerStreamControllers[0].add(FilterPredicate(
      (o) => false,
      Player,
      'name',
      'domain1',
    )),
    expect: () => [PredicateDomain('domain1')],
  );

  blocTest<TestPredicateProducerCubit, FilterPredicate?>(
    """emits an empty FilterPredicate of correct domain when onPredicateRemoved
    is called""",
    build: () => sut,
    act: (bloc) {
      sut.onPredicateRemoved(FilterPredicate(
        (o) => false,
        Player,
        'name',
        'domain1',
      ));
      sut.onPredicateRemoved(FilterPredicate(
        (o) => false,
        Player,
        'name',
        'domain2',
      ));
      sut.onPredicateRemoved(FilterPredicate(
        (o) => false,
        Player,
        'name',
        'non existent domain',
      ));
    },
    expect: () => [
      allOf(
        PredicateDomain('domain1'),
        PredicateFunction(isNull),
      ),
      allOf(
        PredicateDomain('domain2'),
        PredicateFunction(isNull),
      ),
    ],
  );

  blocTest<TestPredicateProducerCubit, FilterPredicate?>(
    'closes all producer streams as the cubit is closed',
    build: () => sut,
    verify: (cubit) {
      for (var controller in producerStreamControllers) {
        expect(controller.isClosed, true);
      }
    },
  );
}
