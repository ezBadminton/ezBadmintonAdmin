import 'package:collection_repository/collection_repository.dart';
import 'package:expect_stream/expect_stream.dart';
import 'package:ez_badminton_admin_app/predicate_filter/common_predicate_producers/playinglevel_predicate_producer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common_matchers/predicate_matchers.dart';

class HasPlayingLevels extends CustomMatcher {
  HasPlayingLevels(matcher)
      : super(
          'Producer with playing levels',
          'playing levels',
          matcher,
        );

  @override
  featureValueOf(actual) =>
      (actual as PlayingLevelPredicateProducer).playingLevels;
}

void main() {
  late PlayingLevelPredicateProducer sut;

  var playingLevels = List<PlayingLevel>.generate(
    3,
    (index) => PlayingLevel(
      id: '$index',
      created: DateTime(2023),
      updated: DateTime(2023),
      name: '$index',
      index: index,
    ),
  );

  setUp(() => sut = PlayingLevelPredicateProducer());

  group('PlayingLevelPredicateProducer input values', () {
    test(
      'initial playing levels are empty',
      () => expect(sut, HasPlayingLevels([])),
    );

    test(
      'playing levels are set according to the toggles',
      () {
        sut.playingLevelToggled(playingLevels[0]);
        expect(sut, HasPlayingLevels([playingLevels[0]]));
        sut.playingLevelToggled(playingLevels[1]);
        sut.playingLevelToggled(playingLevels[2]);
        expect(sut, HasPlayingLevels(playingLevels));
        sut.playingLevelToggled(playingLevels[2]);
        expect(sut, HasPlayingLevels(playingLevels.sublist(0, 2)));
      },
    );

    test(
      'accepts the predicate domain',
      () => expect(sut.producesDomain(playingLevels[0]), true),
    );
  });

  group('PlayingLevelPredicateProducer predicate outputs', () {
    test(
      """FilterPredicates are produced with or without predicate function
      according to the PlayingLevel being toggled on or off""",
      () async {
        sut.playingLevelToggled(playingLevels[0]);
        sut.playingLevelToggled(playingLevels[0]);
        await expectStream(
          sut.predicateStream,
          [
            allOf(
              HasFunction(isNotNull),
              HasDomain(playingLevels[0]),
              HasDisjunction(
                PlayingLevelPredicateProducer.playingLevelDisjunction,
              ),
              HasInputType(Competition),
            ),
            allOf(
              HasFunction(isNull),
              HasDomain(playingLevels[0]),
              HasInputType(Competition),
            ),
          ],
        );
      },
    );

    test(
      """produces empty FilterPredicates when produceEmptyPredicate is
    called""",
      () async {
        sut.playingLevelToggled(playingLevels[0]);
        sut.produceEmptyPredicate(playingLevels[0]);
        expect(sut, HasPlayingLevels([]));
        await expectStream(
          sut.predicateStream,
          [
            HasFunction(isNotNull),
            allOf(
              HasFunction(isNull),
              HasDomain(playingLevels[0]),
            ),
          ],
        );
      },
    );
  });

  group('PlayingLevelPredicateProducer player filtering', () {
    var level0Competition = Competition.newCompetition(
      teamSize: 2,
      genderCategory: GenderCategory.mixed,
      playingLevel: playingLevels[0],
    ).copyWith(
      id: 'lvl0',
    );
    var level1Competition = Competition.newCompetition(
      teamSize: 2,
      genderCategory: GenderCategory.mixed,
      playingLevel: playingLevels[1],
    ).copyWith(
      id: 'lvl1',
    );
    var level2Competition = Competition.newCompetition(
      teamSize: 2,
      genderCategory: GenderCategory.mixed,
      playingLevel: playingLevels[2],
    ).copyWith(
      id: 'lvl2',
    );
    var competitions = [
      level0Competition,
      level1Competition,
      level2Competition
    ];
    test(
      'produced predicates filter players by playing level',
      () async {
        sut.playingLevelToggled(playingLevels[0]);
        sut.playingLevelToggled(playingLevels[2]);
        sut.playingLevelToggled(playingLevels[1]);
        await expectStream(
          sut.predicateStream,
          [
            HasFilterResult([level0Competition], items: competitions),
            HasFilterResult([level2Competition], items: competitions),
            HasFilterResult([level1Competition], items: competitions),
          ],
        );
      },
    );
  });
}
