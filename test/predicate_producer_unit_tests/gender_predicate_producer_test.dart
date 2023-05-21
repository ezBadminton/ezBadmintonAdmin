import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/player_filter/player_filter.dart';
import 'package:flutter_test/flutter_test.dart';

import 'predicate_matchers.dart';

class HasGender extends CustomMatcher {
  HasGender(matcher)
      : super(
          'Producer with gender of',
          'gender',
          matcher,
        );

  @override
  featureValueOf(actual) => (actual as GenderPredicateProducer).gender;
}

void main() {
  late GenderPredicateProducer sut;

  setUp(() => sut = GenderPredicateProducer());

  group('GenderPredicateProducer input values', () {
    test(
      'initial gender is null',
      () => expect(sut, HasGender(null)),
    );

    test(
      """retains the gender that is put in and resets to null when the same
      gender is input twice in a row,
      sets gender to null when Gender.none is put in""",
      () {
        sut.genderChanged(Gender.female);
        expect(sut, HasGender(Gender.female));
        sut.genderChanged(Gender.male);
        expect(sut, HasGender(Gender.male));
        sut.genderChanged(Gender.male);
        expect(sut, HasGender(null));
        sut.genderChanged(Gender.none);
        expect(sut, HasGender(null));
      },
    );

    test(
      'accepts the predicate domain',
      () => expect(
          sut.producesDomain(GenderPredicateProducer.genderDomain), true),
    );
  });

  group('GenderPredicateProducer predicate outputs', () {
    test(
      """produces a FilterPredicate on change and does not re-emit an empty
      predicate""",
      () async {
        sut.genderChanged(Gender.female);
        sut.genderChanged(null);
        sut.genderChanged(null);
        sut.genderChanged(Gender.none);
        await expectStream(
          sut.predicateStream,
          [
            allOf(
              HasFunction(isNotNull),
              HasDomain(GenderPredicateProducer.genderDomain),
              HasDisjunction(isEmpty),
              HasInputType(Player),
            ),
            allOf(
              HasFunction(isNull),
              HasDomain(GenderPredicateProducer.genderDomain),
              HasInputType(Player),
            ),
          ],
        );
      },
    );

    test(
      """produces empty FilterPredicates when produceEmptyPredicate is
    called""",
      () async {
        sut.genderChanged(Gender.female);
        sut.produceEmptyPredicate(GenderPredicateProducer.genderDomain);
        expect(sut, HasGender(null));
        await expectStream(
          sut.predicateStream,
          [
            HasFunction(isNotNull),
            HasFunction(isNull),
          ],
        );
      },
    );
  });

  group('GenderPredicateProducer player filtering', () {
    var femalePlayer = Player.newPlayer.copyWith(gender: Gender.female);
    var malePlayer = Player.newPlayer.copyWith(gender: Gender.male);
    test(
      'produced predicates filter players by gender',
      () async {
        sut.genderChanged(Gender.female);
        sut.genderChanged(Gender.male);
        await expectStream(
          sut.predicateStream,
          [
            HasFilterResult([femalePlayer], items: [femalePlayer, malePlayer]),
            HasFilterResult([malePlayer], items: [femalePlayer, malePlayer]),
          ],
        );
      },
    );
  });
}
