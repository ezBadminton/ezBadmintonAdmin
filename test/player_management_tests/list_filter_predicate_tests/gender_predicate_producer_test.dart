import 'package:collection_repository/collection_repository.dart';
import 'package:expect_stream/expect_stream.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate_producers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common_matchers/predicate_matchers.dart';

class HasCategories extends CustomMatcher {
  HasCategories(matcher)
      : super(
          'Producer with gender of',
          'gender',
          matcher,
        );

  @override
  featureValueOf(actual) =>
      (actual as GenderCategoryPredicateProducer).categories;
}

void main() {
  late GenderCategoryPredicateProducer sut;

  setUp(() => sut = GenderCategoryPredicateProducer());

  group('GenderCategoryPredicateProducer input values', () {
    test(
      'initial categories',
      () => expect(sut, HasCategories(isEmpty)),
    );

    test(
      'category toggles',
      () {
        sut.categoryToggled(GenderCategory.female);
        expect(sut, HasCategories([GenderCategory.female]));
        sut.categoryToggled(GenderCategory.male);
        expect(
          sut,
          HasCategories(containsAll([
            GenderCategory.female,
            GenderCategory.male,
          ])),
        );
        sut.categoryToggled(GenderCategory.female);
        expect(sut, HasCategories([GenderCategory.male]));
      },
    );

    test(
      'accepts the predicate domain',
      () {
        expect(sut.producesDomain(GenderCategory.female), true);
        expect(sut.producesDomain('somestring'), false);
      },
    );
  });

  group('GenderCategoryPredicateProducer predicate outputs', () {
    test(
      'category toggles',
      () async {
        sut.categoryToggled(GenderCategory.female);
        sut.categoryToggled(GenderCategory.female);
        await expectStream(
          sut.predicateStream,
          [
            allOf(
              HasFunction(isNotNull),
              HasDomain(GenderCategory.female),
              HasDisjunction(
                GenderCategoryPredicateProducer.categoryDisjunction,
              ),
              HasInputType(Competition),
            ),
            allOf(
              HasFunction(isNull),
              HasDomain(GenderCategory.female),
              HasInputType(Competition),
            ),
          ],
        );
      },
    );

    test(
      'produceEmptyPredicate',
      () async {
        sut.categoryToggled(GenderCategory.female);
        sut.produceEmptyPredicate(GenderCategory.female);
        expect(sut, HasCategories(isEmpty));
        await expectStream(
          sut.predicateStream,
          [
            HasFunction(isNotNull),
            allOf(
              HasFunction(isNull),
              HasDomain(GenderCategory.female),
            ),
          ],
        );
      },
    );
  });

  group('GenderCategoryPredicateProducer competition filtering', () {
    Competition womensCompetition = Competition.newCompetition(
        teamSize: 1, genderCategory: GenderCategory.female);
    Competition mensCompetition = Competition.newCompetition(
        teamSize: 1, genderCategory: GenderCategory.male);
    test(
      'filter results',
      () async {
        sut.categoryToggled(GenderCategory.female);
        sut.categoryToggled(GenderCategory.male);
        await expectStream(
          sut.predicateStream,
          [
            HasFilterResult(
              [womensCompetition],
              items: [womensCompetition, mensCompetition],
            ),
            HasFilterResult(
              [mensCompetition],
              items: [womensCompetition, mensCompetition],
            ),
          ],
        );
      },
    );
  });
}
