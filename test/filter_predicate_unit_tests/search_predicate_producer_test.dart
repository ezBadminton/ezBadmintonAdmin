import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:expect_stream/expect_stream.dart';
import 'package:ez_badminton_admin_app/player_management/player_filter/player_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ez_badminton_admin_app/constants.dart';

import '../common_matchers/predicate_matchers.dart';

class HasSearchTerm extends CustomMatcher {
  HasSearchTerm(matcher)
      : super(
          'Producer with search term',
          'search term',
          matcher,
        );

  @override
  featureValueOf(actual) => (actual as SearchPredicateProducer).searchTerm;
}

void main() {
  late SearchPredicateProducer sut;

  setUp(() => sut = SearchPredicateProducer());

  group('SearchPredicateProducer input values', () {
    test(
      'initial search term is empty',
      () => expect(sut, HasSearchTerm(isEmpty)),
    );

    test(
      'retains the search term that is put in',
      () {
        sut.searchTermChanged('a');
        expect(sut, HasSearchTerm('a'));
        sut.searchTermChanged(' aB!3 ');
        expect(sut, HasSearchTerm(' aB!3 '));
        sut.searchTermChanged(
          List<String>.generate(80, (_) => 'A').join(),
        );
        expect(
          sut,
          HasSearchTerm(
            List<String>.generate(80, (_) => 'A').join(),
          ),
        );
      },
    );

    test(
      'accepts the predicate domain',
      () => expect(
          sut.producesDomain(SearchPredicateProducer.searchDomain), true),
    );
  });

  group('SearchPredicateProducer predicate outputs', () {
    test(
      """produces FilterPredicates when the search term changes but stops at the
      character limit (playerSearchMaxLength),
      emits an empty FilterPredicate when an empty search term is entered""",
      () async {
        sut.searchTermChanged('hello');
        sut.searchTermChanged('');
        sut.searchTermChanged(
          List<String>.generate(playerSearchMaxLength, (_) => 'A').join(),
        );
        sut.searchTermChanged(
          List<String>.generate(playerSearchMaxLength + 1, (_) => 'A').join(),
        );
        await expectStream(
          sut.predicateStream,
          [
            allOf(
              HasFunction(isNotNull),
              HasDomain(SearchPredicateProducer.searchDomain),
              HasDisjunction(isEmpty),
              HasInputType(Player),
            ),
            allOf(
              HasFunction(isNull),
              HasDomain(SearchPredicateProducer.searchDomain),
              HasInputType(Player),
            ),
            HasFunction(isNotNull),
          ],
        );
      },
    );

    test(
      'produces empty FilterPredicate when produceEmptyPredicate is called',
      () async {
        sut.searchTermChanged('world');
        sut.produceEmptyPredicate(SearchPredicateProducer.searchDomain);
        expect(sut, HasSearchTerm(isEmpty));
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

  group('SearchPredicateProducer player filtering', () {
    var namedClubs = ['A', 'b', 'c']
        .map(
          (name) => Club(
            id: name,
            created: DateTime(2023),
            updated: DateTime(2023),
            name: name,
          ),
        )
        .toList();

    var namedPlayers = [
      ['d', 'x'],
      ['E', 'y'],
      ['F', 'Z']
    ]
        .mapIndexed(
          (index, name) => Player.newPlayer().copyWith(
            firstName: name[0],
            lastName: name[1],
            club: namedClubs[index],
          ),
        )
        .toList();
    test(
      """produced predicates filter players by first name, last name
      and club name""",
      () async {
        sut.searchTermChanged('g'); // search for non-existent name
        sut.searchTermChanged('a'); // by club name
        sut.searchTermChanged('e Y'); // by first and last name
        sut.searchTermChanged('f'); // by first name
        sut.searchTermChanged('x'); // by last name
        sut.searchTermChanged('   X  '); // leading/trailing space
        await expectStream(
          sut.predicateStream,
          [
            HasFilterResult([], items: namedPlayers),
            HasFilterResult([namedPlayers[0]], items: namedPlayers),
            HasFilterResult([namedPlayers[1]], items: namedPlayers),
            HasFilterResult([namedPlayers[2]], items: namedPlayers),
            HasFilterResult([namedPlayers[0]], items: namedPlayers),
            HasFilterResult([namedPlayers[0]], items: namedPlayers),
          ],
        );
      },
    );
  });
}
