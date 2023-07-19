import 'package:collection_repository/collection_repository.dart';
import 'package:expect_stream/expect_stream.dart';
import 'package:ez_badminton_admin_app/player_management/player_filter/player_filter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common_matchers/predicate_matchers.dart';

void main() {
  late StatusPredicateProducer sut;

  setUp(() => sut = StatusPredicateProducer());

  group('StatusPredicateProducer input values', () {
    test('initial status list is empty', () {
      expect(sut.statusList, isEmpty);
    });

    test('status toggles', () {
      sut.statusToggled(PlayerStatus.attending);
      expect(sut.statusList, [PlayerStatus.attending]);
      sut.statusToggled(PlayerStatus.notAttending);
      sut.statusToggled(PlayerStatus.injured);
      expect(
        sut.statusList,
        [
          PlayerStatus.attending,
          PlayerStatus.notAttending,
          PlayerStatus.injured,
        ],
      );
      sut.statusToggled(PlayerStatus.notAttending);
      expect(
        sut.statusList,
        [
          PlayerStatus.attending,
          PlayerStatus.injured,
        ],
      );
    });

    test('predicate domain', () {
      expect(sut.producesDomain(PlayerStatus.attending), isTrue);
      expect(sut.producesDomain('somestring'), isFalse);
    });
  });

  group('StatusPredicateProducer predicate outputs', () {
    test('status toggles', () async {
      sut.statusToggled(PlayerStatus.attending);
      sut.statusToggled(PlayerStatus.attending);
      await expectStream(sut.predicateStream, [
        allOf(
          HasFunction(isNotNull),
          HasDomain(PlayerStatus.attending),
          HasDisjunction(StatusPredicateProducer.statusDisjunction),
          HasInputType(Player),
        ),
        allOf(
          HasFunction(isNull),
          HasDomain(PlayerStatus.attending),
          HasInputType(Player),
        ),
      ]);
    });

    test('produce empty predicate', () async {
      sut.statusToggled(PlayerStatus.attending);
      sut.produceEmptyPredicate(PlayerStatus.attending);
      expect(sut.statusList, isEmpty);
      await expectStream(
        sut.predicateStream,
        [
          HasFunction(isNotNull),
          allOf(
            HasFunction(isNull),
            HasDomain(PlayerStatus.attending),
          ),
        ],
      );
    });
  });

  group('StatusPredicateProducer player filtering', () {
    var attendingPlayer = Player.newPlayer()
        .copyWith(id: 'attending', status: PlayerStatus.attending);
    var notAttendingPlayer = Player.newPlayer()
        .copyWith(id: 'not-attending', status: PlayerStatus.notAttending);

    test('filter result', () async {
      sut.statusToggled(PlayerStatus.attending);
      sut.statusToggled(PlayerStatus.notAttending);
      await expectStream(
        sut.predicateStream,
        [
          HasFilterResult(
            [attendingPlayer],
            items: [attendingPlayer, notAttendingPlayer],
          ),
          HasFilterResult(
            [notAttendingPlayer],
            items: [attendingPlayer, notAttendingPlayer],
          ),
        ],
      );
    });
  });
}
