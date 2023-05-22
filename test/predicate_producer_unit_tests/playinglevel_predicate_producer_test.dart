import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/player_filter/player_filter.dart';
import 'package:flutter_test/flutter_test.dart';

import 'predicate_matchers.dart';

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
                  PlayingLevelPredicateProducer.playingLevelDisjunction),
              HasInputType(Player),
            ),
            allOf(
              HasFunction(isNull),
              HasDomain(playingLevels[0]),
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
    var level0Player =
        Player.newPlayer().copyWith(playingLevel: playingLevels[0]);
    var level1Player =
        Player.newPlayer().copyWith(playingLevel: playingLevels[1]);
    var level2Player =
        Player.newPlayer().copyWith(playingLevel: playingLevels[2]);
    var players = [level0Player, level1Player, level2Player];
    test(
      'produced predicates filter players by playing level',
      () async {
        sut.playingLevelToggled(playingLevels[0]);
        sut.playingLevelToggled(playingLevels[2]);
        sut.playingLevelToggled(playingLevels[1]);
        await expectStream(
          sut.predicateStream,
          [
            HasFilterResult([level0Player], items: players),
            HasFilterResult([level2Player], items: players),
            HasFilterResult([level1Player], items: players),
          ],
        );
      },
    );
  });
}
