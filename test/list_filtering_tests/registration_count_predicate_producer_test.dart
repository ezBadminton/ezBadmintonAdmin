import 'package:collection_repository/collection_repository.dart';
import 'package:expect_stream/expect_stream.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_filter/competition_filter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common_matchers/predicate_matchers.dart';

class HasOverCount extends CustomMatcher {
  HasOverCount(matcher)
      : super(
          'PredicateProducer with overCount',
          'input String',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.overCount;
}

class HasUnderCount extends CustomMatcher {
  HasUnderCount(matcher)
      : super(
          'PredicateProducer with underCount',
          'input String',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.underCount;
}

// 3 competitions with 0, 1 and 2 teams registered
List<Competition> competitions = List.generate(
  3,
  (index) => Competition.newCompetition(
    teamSize: 2,
    genderCategory: GenderCategory.mixed,
    registrations: List.generate(
      index,
      (i) => Team.newTeam().copyWith(id: 'Team-$index-$i'),
    ),
  ).copyWith(id: 'Competition-$index'),
).toList();

void main() {
  late RegistrationCountPredicateProducer sut;

  setUp(() => sut = RegistrationCountPredicateProducer());

  group('RegistrationCountPredicateProducer', () {
    test('initial state', () {
      expect(sut, HasOverCount(isEmpty));
      expect(sut, HasUnderCount(isEmpty));
    });

    test('input changes', () {
      sut.overRegistrationsChanged('10');
      sut.underRegistrationsChanged('20');

      expect(sut, HasOverCount('10'));
      expect(sut, HasUnderCount('20'));
    });

    test('produces domain', () {
      expect(
        sut.producesDomain(
            RegistrationCountPredicateProducer.overRegistrationsDomain),
        isTrue,
      );
      expect(
        sut.producesDomain(
            RegistrationCountPredicateProducer.underRegistrationsDomain),
        isTrue,
      );
      expect(sut.producesDomain('string'), isFalse);
    });

    test('Predicate emissions', () async {
      sut.overRegistrationsChanged('10');
      sut.produceRegistrationCountPredicates();

      await expectStream(sut.predicateStream, [
        allOf(
          HasFunction(isNotNull),
          HasDomain(
            RegistrationCountPredicateProducer.overRegistrationsDomain,
          ),
          HasDisjunction(isNull),
          HasInputType(Competition),
        ),
        allOf(
          HasFunction(isNull),
          HasDomain(
            RegistrationCountPredicateProducer.underRegistrationsDomain,
          ),
          HasDisjunction(isNull),
          HasInputType(Competition),
        ),
      ]);
    });

    test('produce empty predicate', () async {
      sut.overRegistrationsChanged('10');
      sut.underRegistrationsChanged('20');

      sut.produceEmptyPredicate(
        RegistrationCountPredicateProducer.overRegistrationsDomain,
      );
      expect(sut, HasOverCount(isEmpty));

      sut.produceEmptyPredicate(
        RegistrationCountPredicateProducer.underRegistrationsDomain,
      );
      expect(sut, HasUnderCount(isEmpty));

      await expectStream(sut.predicateStream, [
        allOf(
          HasFunction(isNull),
          HasDomain(
            RegistrationCountPredicateProducer.overRegistrationsDomain,
          ),
        ),
        allOf(
          HasFunction(isNull),
          HasDomain(
            RegistrationCountPredicateProducer.underRegistrationsDomain,
          ),
        ),
      ]);
    });

    test('filtering', () async {
      sut.overRegistrationsChanged('2');
      sut.underRegistrationsChanged('1');
      sut.produceRegistrationCountPredicates();

      await expectStream(sut.predicateStream, [
        HasFilterResult(
          [competitions[2]],
          items: competitions,
        ),
        HasFilterResult(
          [competitions[0], competitions[1]],
          items: competitions,
        ),
      ]);
    });
  });
}
