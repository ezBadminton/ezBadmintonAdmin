import 'package:bloc_test/bloc_test.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_filter_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class HasPredicates extends CustomMatcher {
  HasPredicates(matcher)
      : super(
          'State with FilterPredicate map that is',
          '<Type,FilterPredicate> map',
          matcher,
        );
  @override
  featureValueOf(actual) => (actual as PredicateFilterState).filterPredicates;
}

class HasFilter extends CustomMatcher {
  HasFilter(matcher)
      : super(
          'State with filter map that is',
          '<Type,Predicate> map',
          matcher,
        );
  @override
  featureValueOf(actual) => (actual as PredicateFilterState).filters;
}

class OfType<T> extends CustomMatcher {
  OfType(matcher)
      : super(
          'map with type key (${T.toString()}) that is',
          'type key',
          matcher,
        );
  @override
  featureValueOf(actual) => (actual as Map<Type, dynamic>)[T];
}

class WithFilterResult extends CustomMatcher {
  WithFilterResult(matcher, {required this.item})
      : super(
          'bool result of a filter on item (${item.toString()})',
          'bool filter result',
          matcher,
        );
  final dynamic item;
  @override
  featureValueOf(actual) => (actual as Predicate)(item);
}

void main() {
  late PredicateFilterCubit sut;

  var emptyStringPredicate = FilterPredicate(
    (s) => (s as String).isEmpty,
    String,
    'empty',
    'string',
  );

  var nonEmptyStringPredicate = FilterPredicate(
    (s) => (s as String).isNotEmpty,
    String,
    'not empty',
    'string',
  );

  var hwStringPredicate = FilterPredicate(
    (s) => (s as String).contains('hello world'),
    String,
    'contains hello world',
    'contains hello world',
  );

  var exclamationStringPredicate = FilterPredicate(
    (s) => (s as String)[s.length - 1] == '!',
    String,
    'ends with !',
    'ends with !',
  );

  var bigNumberPredicate = FilterPredicate(
    (i) => (i as int) > 420,
    int,
    'larger than 420',
    'larger than',
  );

  var emptyBigNumberPredicate = const FilterPredicate(
    null,
    int,
    'larger than 420',
    'larger than',
  );

  var disjoinedIs6Predicate = FilterPredicate(
    (i) => (i as int) == 6,
    int,
    'is 6',
    'is 6',
    'number disjunction',
  );

  var disjoinedIs9Predicate = FilterPredicate(
    (i) => (i as int) == 9,
    int,
    'is 9',
    'is 9',
    'number disjunction',
  );

  var isEvenPredicate = FilterPredicate(
    (i) => (i as int) % 2 == 0,
    int,
    'is even',
    'even-ness',
  );

  setUp(() => sut = PredicateFilterCubit());

  test('initial state has empty list of predicates and filters', () {
    expect(sut.state.filterPredicates, isEmpty);
    expect(sut.state.filters, isEmpty);
  });

  blocTest<PredicateFilterCubit, PredicateFilterState>(
    'consumed predicates are retained, mapped by type and updates are emitted.',
    build: () => sut,
    act: (cubit) {
      cubit.consumePredicate(emptyStringPredicate);
      cubit.consumePredicate(hwStringPredicate);
      cubit.consumePredicate(bigNumberPredicate);
    },
    expect: () => [
      allOf(
        HasFilter(OfType<String>(isNotNull)),
        HasPredicates(OfType<String>([emptyStringPredicate])),
      ),
      allOf(
        HasFilter(OfType<String>(isNotNull)),
        HasPredicates(
          OfType<String>([emptyStringPredicate, hwStringPredicate]),
        ),
      ),
      allOf(
        HasFilter(OfType<String>(isNotNull)),
        HasFilter(OfType<int>(isNotNull)),
        HasPredicates(allOf(
          OfType<String>([emptyStringPredicate, hwStringPredicate]),
          OfType<int>([bigNumberPredicate]),
        )),
      ),
    ],
  );

  blocTest<PredicateFilterCubit, PredicateFilterState>(
    """consumed predicates are replaced by subsequently consumed predicates of
    the same domain.""",
    build: () => sut,
    act: (cubit) {
      cubit.consumePredicate(emptyStringPredicate);
      cubit.consumePredicate(nonEmptyStringPredicate);
    },
    expect: () => [
      HasPredicates(OfType<String>([emptyStringPredicate])),
      HasPredicates(OfType<String>([nonEmptyStringPredicate])),
    ],
  );

  blocTest<PredicateFilterCubit, PredicateFilterState>(
    """consumed predicates that have no function ("empty predicate") lead to the
    deletion of a present predicate with the same domain""",
    build: () => sut,
    act: (cubit) {
      cubit.consumePredicate(bigNumberPredicate);
      cubit.consumePredicate(emptyBigNumberPredicate);
    },
    expect: () => [
      HasPredicates(OfType<int>([bigNumberPredicate])),
      HasPredicates(OfType<int>(isNull)),
    ],
  );

  blocTest<PredicateFilterCubit, PredicateFilterState>(
    """consumed predicates of one type result in a conjoined filter for
    that type""",
    build: () => sut,
    skip: 1,
    act: (cubit) {
      cubit.consumePredicate(hwStringPredicate);
      cubit.consumePredicate(exclamationStringPredicate);
    },
    expect: () => [
      HasFilter(OfType<String>(allOf(
        WithFilterResult(false, item: 'hello world'),
        WithFilterResult(false, item: 'yo world!'),
        WithFilterResult(true, item: 'hello world!'),
      ))),
    ],
  );

  blocTest<PredicateFilterCubit, PredicateFilterState>(
    """consumed predicates of one type and disjunction result in a disjoined
    filter for that type,
    predicates that are not in that disjunction are conjoined with the
    disjunction""",
    build: () => sut,
    skip: 1,
    act: (cubit) {
      cubit.consumePredicate(disjoinedIs6Predicate);
      cubit.consumePredicate(disjoinedIs9Predicate);
      cubit.consumePredicate(isEvenPredicate);
    },
    expect: () => [
      HasFilter(OfType<int>(allOf(
        WithFilterResult(false, item: 10),
        WithFilterResult(true, item: 6),
        WithFilterResult(true, item: 9),
      ))),
      HasFilter(OfType<int>(allOf(
        WithFilterResult(false, item: 10),
        WithFilterResult(true, item: 6),
        WithFilterResult(false, item: 9),
      ))),
    ],
  );
}
