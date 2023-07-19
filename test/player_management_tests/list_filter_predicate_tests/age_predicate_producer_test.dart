import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/player_filter/player_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expect_stream/expect_stream.dart';

import '../../common_matchers/predicate_matchers.dart';

class HasAge extends CustomMatcher {
  HasAge(matcher, {required this.over})
      : super(
          '${over ? 'over' : 'under'} age predicate of',
          'years',
          matcher,
        );

  final bool over;

  @override
  featureValueOf(actual) => over
      ? (actual as AgePredicateProducer).overAge
      : (actual as AgePredicateProducer).underAge;
}

void main() {
  late AgePredicateProducer sut;

  setUp(() => sut = AgePredicateProducer());

  group('AgePredicateProducer input values', () {
    test('initial age values are empty strings', () {
      expect(
        sut,
        allOf(HasAge('', over: true), HasAge('', over: false)),
      );
    });

    test('age values that are put in are saved', () {
      sut.overAgeChanged('21');
      sut.underAgeChanged('42');
      expect(
        sut,
        allOf(HasAge('21', over: true), HasAge('42', over: false)),
      );
    });

    test('accepts domains', () {
      expect(sut.producesDomain(AgePredicateProducer.overAgeDomain), true);
      expect(sut.producesDomain(AgePredicateProducer.underAgeDomain), true);
    });
  });

  group('AgePredicateProducer predicate outputs', () {
    test('produces FilterPredicate for both age inputs', () async {
      sut.overAgeChanged('25');
      sut.underAgeChanged('30');
      sut.produceAgePredicates();
      await expectStream(
        sut.predicateStream,
        [
          allOf(
            HasFunction(isNotNull),
            HasDomain(AgePredicateProducer.overAgeDomain),
            HasDisjunction(isNull),
            HasInputType(Player),
          ),
          allOf(
            HasFunction(isNotNull),
            HasDomain(AgePredicateProducer.underAgeDomain),
            HasDisjunction(isNull),
            HasInputType(Player),
          ),
        ],
      );
    });

    test('only produces FilterPredicate for valid age inputs', () async {
      sut.overAgeChanged('25');
      sut.underAgeChanged('-30');
      sut.produceAgePredicates();
      await expectStream(
        sut.predicateStream,
        [
          HasDomain(AgePredicateProducer.overAgeDomain),
        ],
      );
    });

    test('produces empty FilterPredicate for empty age inputs', () async {
      sut.overAgeChanged('25');
      sut.underAgeChanged('');
      sut.produceAgePredicates();
      await expectStream(
        sut.predicateStream,
        [
          HasFunction(isNotNull),
          allOf(
            HasFunction(isNull),
            HasDomain(AgePredicateProducer.underAgeDomain),
            HasInputType(Player),
          ),
        ],
      );
    });

    test("""produces empty FilterPredicates when produceEmptyPredicate is
    called""", () async {
      sut.overAgeChanged('25');
      sut.underAgeChanged('xyz');
      sut.produceEmptyPredicate(AgePredicateProducer.overAgeDomain);
      expect(sut.overAge, '');
      sut.produceEmptyPredicate(AgePredicateProducer.underAgeDomain);
      expect(sut.underAge, '');
      await expectStream(
        sut.predicateStream,
        [
          HasFunction(isNull),
          HasFunction(isNull),
        ],
      );
    });
  });

  group('AgePredicateProducer player filtering', () {
    var agedPlayers = [3, 14, 20].mapIndexed((index, age) {
      var today = DateTime.now();
      var dateOfBirth =
          DateTime(today.year - age, today.month, today.day - index);
      return Player.newPlayer().copyWith(dateOfBirth: dateOfBirth);
    }).toList();

    test('produced predicates filter players by age', () async {
      sut.overAgeChanged('3');
      sut.underAgeChanged('21');
      sut.produceAgePredicates();
      sut.overAgeChanged('15');
      sut.underAgeChanged('20');
      sut.produceAgePredicates();
      await expectStream(
        sut.predicateStream,
        [
          HasFilterResult(agedPlayers, items: agedPlayers),
          HasFilterResult(agedPlayers, items: agedPlayers),
          HasFilterResult([agedPlayers[2]], items: agedPlayers),
          HasFilterResult(agedPlayers.sublist(0, 2), items: agedPlayers),
        ],
      );
    });
  });

  test('PredicateProducer.close() closes the stream', () async {
    await expectStream(sut.predicateStream, []);
    await sut.close();
    // ignore: invalid_use_of_protected_member
    expect(sut.predicateStreamController.isClosed, isTrue);
  });
}
