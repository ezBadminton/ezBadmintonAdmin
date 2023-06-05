import 'package:collection_repository/collection_repository.dart';
import 'package:expect_stream/expect_stream.dart';
import 'package:ez_badminton_admin_app/player_management/player_filter/player_filter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common_matchers/predicate_matchers.dart';

class HasCompetitionTypes extends CustomMatcher {
  HasCompetitionTypes(matcher)
      : super(
          'Producer with competition types',
          'competition types',
          matcher,
        );

  @override
  featureValueOf(actual) =>
      (actual as CompetitionTypePredicateProducer).competitionTypes;
}

void main() {
  late CompetitionTypePredicateProducer sut;

  setUp(() => sut = CompetitionTypePredicateProducer());

  group('CompetitionTypePredicateProducer input values', () {
    test(
      'initial competition types are empty',
      () => expect(sut, HasCompetitionTypes([])),
    );

    test(
      'competition types are set according to the toggles',
      () {
        sut.competitionTypeToggled(CompetitionType.doubles);
        expect(
          sut,
          HasCompetitionTypes(
            [CompetitionType.doubles],
          ),
        );
        sut.competitionTypeToggled(CompetitionType.singles);
        expect(
          sut,
          HasCompetitionTypes([
            CompetitionType.doubles,
            CompetitionType.singles,
          ]),
        );
        sut.competitionTypeToggled(CompetitionType.singles);
        expect(
          sut,
          HasCompetitionTypes([
            CompetitionType.doubles,
          ]),
        );
      },
    );

    test(
      'accepts the predicate domain',
      () => expect(sut.producesDomain(CompetitionType.mixed), true),
    );
  });

  group('CompetitionTypePredicateProducer predicate outputs', () {
    test(
      """FilterPredicates are produced with or without predicate function
      according to the CompetitionType being toggled on or off""",
      () async {
        sut.competitionTypeToggled(CompetitionType.mixed);
        sut.competitionTypeToggled(CompetitionType.mixed);
        await expectStream(
          sut.predicateStream,
          [
            allOf(
              HasFunction(isNotNull),
              HasDomain(CompetitionType.mixed),
              HasDisjunction(
                  CompetitionTypePredicateProducer.competitionDisjunction),
              HasInputType(Competition),
            ),
            allOf(
              HasFunction(isNull),
              HasDomain(CompetitionType.mixed),
              HasInputType(Competition),
            ),
          ],
        );
      },
    );

    test(
      'produces empty FilterPredicate when produceEmptyPredicate is called',
      () async {
        sut.competitionTypeToggled(CompetitionType.mixed);
        sut.produceEmptyPredicate(CompetitionType.mixed);
        expect(sut, HasCompetitionTypes([]));
        await expectStream(
          sut.predicateStream,
          [
            HasFunction(isNotNull),
            allOf(
              HasFunction(isNull),
              HasDomain(CompetitionType.mixed),
            ),
          ],
        );
      },
    );
  });

  group('CompetitionTypePredicateProducer competition filtering', () {
    var singles = Competition.newCompetition(
      teamSize: 1,
      genderCategory: GenderCategory.any,
      registrations: const [],
    );
    var mixed = Competition.newCompetition(
      teamSize: 2,
      genderCategory: GenderCategory.mixed,
      registrations: const [],
    );
    var doubles = Competition.newCompetition(
      teamSize: 2,
      genderCategory: GenderCategory.female,
      registrations: const [],
    );
    var other = Competition.newCompetition(
      teamSize: 4,
      genderCategory: GenderCategory.any,
      registrations: const [],
    );
    var competitions = [singles, mixed, doubles, other];
    var competitionTypes = [
      CompetitionType.singles,
      CompetitionType.mixed,
      CompetitionType.doubles,
      CompetitionType.other,
    ];

    test(
      'produced predicates filter competitions by competition type',
      () async {
        for (var competitionType in competitionTypes) {
          sut.competitionTypeToggled(competitionType);
        }
        await expectStream(
          sut.predicateStream,
          [
            for (var competition in competitions)
              HasFilterResult([competition], items: competitions),
          ],
        );
      },
    );
  });
}
