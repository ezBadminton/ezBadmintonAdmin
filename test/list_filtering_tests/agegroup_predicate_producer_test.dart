import 'package:collection_repository/collection_repository.dart';
import 'package:expect_stream/expect_stream.dart';
import 'package:ez_badminton_admin_app/predicate_filter/common_predicate_producers/agegroup_predicate_producer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common_matchers/predicate_matchers.dart';

class HasAgeGroups extends CustomMatcher {
  HasAgeGroups(matcher)
      : super(
          'PredicateProducer with age groups',
          'List<AgeGroup>',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.ageGroups;
}

List<AgeGroup> ageGroups = List.generate(
  3,
  (index) => AgeGroup.newAgeGroup(type: AgeGroupType.over, age: index)
      .copyWith(id: 'AgeGroup-$index'),
);

void main() {
  late AgeGroupPredicateProducer sut;

  setUp(() => sut = AgeGroupPredicateProducer());

  group('AgeGroupPredicateProducer', () {
    test('initial state', () {
      expect(sut, HasAgeGroups(isEmpty));
    });

    test('produces domain', () {
      expect(sut.producesDomain(ageGroups[0]), isTrue);
      expect(sut.producesDomain('string'), isFalse);
    });

    test('AgeGroup toggles', () {
      sut.ageGroupToggled(ageGroups[0]);
      expect(sut, HasAgeGroups([ageGroups[0]]));

      sut.ageGroupToggled(ageGroups[1]);
      expect(sut, HasAgeGroups(containsAll([ageGroups[0], ageGroups[1]])));

      sut.ageGroupToggled(ageGroups[0]);
      expect(sut, HasAgeGroups([ageGroups[1]]));
    });

    test('Predicate emissions', () async {
      sut.ageGroupToggled(ageGroups[0]);
      sut.ageGroupToggled(ageGroups[0]);

      await expectStream(sut.predicateStream, [
        allOf(
          HasFunction(isNotNull),
          HasDomain(ageGroups[0]),
          HasDisjunction(AgeGroupPredicateProducer.ageGroupDisjunction),
          HasInputType(Competition),
        ),
        allOf(
          HasFunction(isNull),
          HasDomain(ageGroups[0]),
          HasInputType(Competition),
        ),
      ]);
    });

    test('produce empty predicate', () async {
      sut.produceEmptyPredicate(ageGroups[0]);
      sut.ageGroupToggled(ageGroups[0]);
      sut.produceEmptyPredicate(ageGroups[0]);

      await expectStream(sut.predicateStream, [
        HasFunction(isNotNull),
        allOf(
          HasFunction(isNull),
          HasDomain(ageGroups[0]),
        ),
      ]);
    });

    test('filtering', () async {
      List<Competition> competitions = ageGroups
          .map((ageGroup) => Competition.newCompetition(
                teamSize: 2,
                genderCategory: GenderCategory.mixed,
                ageGroup: ageGroup,
              ))
          .toList();

      sut.ageGroupToggled(ageGroups[0]);
      sut.ageGroupToggled(ageGroups[1]);
      sut.ageGroupToggled(ageGroups[2]);

      await expectStream(sut.predicateStream, [
        HasFilterResult([competitions[0]], items: competitions),
        HasFilterResult([competitions[1]], items: competitions),
        HasFilterResult([competitions[2]], items: competitions),
      ]);
    });
  });
}
