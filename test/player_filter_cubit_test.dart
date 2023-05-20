import 'dart:math';

import 'package:bloc_test/bloc_test.dart';
import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/constants.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_filter_cubit.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_filter_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCollectionRepository<M extends Model> extends Mock
    implements CollectionRepository<M> {}

class HasLoadingStatus extends CustomMatcher {
  HasLoadingStatus(matcher)
      : super(
          'State with LoadingStatus that is',
          'LoadingStatus',
          matcher,
        );
  @override
  featureValueOf(actual) => (actual as PlayerFilterState).loadingStatus;
}

class HasAge extends CustomMatcher {
  HasAge(matcher, {required this.over})
      : super(
          'State with ${over ? 'over' : 'under'} age filter of',
          'years',
          matcher,
        );

  final bool over;

  @override
  featureValueOf(actual) => over
      ? (actual as PlayerFilterState).overAge.value
      : (actual as PlayerFilterState).underAge.value;
}

class HasGender extends CustomMatcher {
  HasGender(matcher)
      : super(
          'State with gender filter of',
          'gender',
          matcher,
        );

  @override
  featureValueOf(actual) => (actual as PlayerFilterState).gender;
}

class HasPlayingLevels extends CustomMatcher {
  HasPlayingLevels(matcher)
      : super(
          'State with playing levels filtered',
          'playing levels',
          matcher,
        );

  @override
  featureValueOf(actual) => (actual as PlayerFilterState).playingLevels;
}

class HasCompetitionTypes extends CustomMatcher {
  HasCompetitionTypes(matcher)
      : super(
          'State with competition types filtered',
          'competition types',
          matcher,
        );

  @override
  featureValueOf(actual) => (actual as PlayerFilterState).competitionTypes;
}

class HasSearchTerm extends CustomMatcher {
  HasSearchTerm(matcher)
      : super(
          'State with text search filter of',
          'search term',
          matcher,
        );

  @override
  featureValueOf(actual) => (actual as PlayerFilterState).searchTerm.value;
}

class HasFilterPredicate extends CustomMatcher {
  HasFilterPredicate(matcher)
      : super(
          'State with a FilterPredicate that is',
          'FilterPredicate',
          matcher,
        );
  @override
  featureValueOf(actual) => (actual as PlayerFilterState).filterPredicate;
}

class WithPredicateFunction extends CustomMatcher {
  WithPredicateFunction(matcher)
      : super(
          'FilterPredicate with a predicate function that is',
          'Predicate function',
          matcher,
        );
  @override
  featureValueOf(actual) => (actual as FilterPredicate).function;
}

class WithPredicateDomain extends CustomMatcher {
  WithPredicateDomain(matcher)
      : super(
          'FilterPredicate with a domain of',
          'Predicate domain',
          matcher,
        );
  @override
  featureValueOf(actual) => (actual as FilterPredicate).domain;
}

class WithPredicateDisjunction extends CustomMatcher {
  WithPredicateDisjunction(matcher)
      : super(
          'FilterPredicate with a disjunction of',
          'Predicate disjunction',
          matcher,
        );
  @override
  featureValueOf(actual) => (actual as FilterPredicate).disjunction;
}

class WithPredicateType extends CustomMatcher {
  WithPredicateType(matcher)
      : super(
          'FilterPredicate with a type of',
          'Predicate type',
          matcher,
        );
  @override
  featureValueOf(actual) => (actual as FilterPredicate).type;
}

class WhereFilterResult extends CustomMatcher {
  WhereFilterResult(matcher, {required this.items})
      : super(
          'FilterPredicate that filters to',
          'filtered items',
          matcher,
        );

  final List<Object> items;

  @override
  featureValueOf(actual) =>
      items.where((item) => (actual as FilterPredicate).function!(item));
}

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

void main() {
  late CollectionRepository<PlayingLevel> playingLevelRepository;
  late PlayerFilterCubit sut;

  void arrangePlayingLevelRepositoryReturns() {
    when(
      () => playingLevelRepository.getList(expand: any(named: 'expand')),
    ).thenAnswer((_) async => playingLevels);
  }

  void arrangePlayingLevelRepositoryThrows() {
    when(
      () => playingLevelRepository.getList(expand: any(named: 'expand')),
    ).thenAnswer((_) async => throw CollectionFetchException('errorCode'));
  }

  setUp(() {
    playingLevelRepository = MockCollectionRepository();
  });

  group(
    'PlayerFilterCubit initial state and loading',
    () {
      test('initial LoadingStatus is loading', () {
        arrangePlayingLevelRepositoryReturns();
        expect(
          PlayerFilterCubit(playingLevelRepository: playingLevelRepository)
              .state,
          HasLoadingStatus(LoadingStatus.loading),
        );
      });

      blocTest<PlayerFilterCubit, PlayerFilterState>(
        'emits LoadingStatus.failed when PlayingLevelRepository throws',
        setUp: () => arrangePlayingLevelRepositoryThrows(),
        build: () => PlayerFilterCubit(
          playingLevelRepository: playingLevelRepository,
        ),
        expect: () => [HasLoadingStatus(LoadingStatus.failed)],
      );

      blocTest<PlayerFilterCubit, PlayerFilterState>(
        """emits playing levels from PlayingLevelRepository
        and LoadingStatus.done when PlayingLevelRepository returns""",
        setUp: () => arrangePlayingLevelRepositoryReturns(),
        build: () => PlayerFilterCubit(
          playingLevelRepository: playingLevelRepository,
        ),
        expect: () => [HasLoadingStatus(LoadingStatus.done)],
        verify: (cubit) => expect(cubit.state.allPlayingLevels, playingLevels),
      );

      blocTest<PlayerFilterCubit, PlayerFilterState>(
        'goes back to LoadingStatus.loading when playing levels are reloaded',
        setUp: () {
          arrangePlayingLevelRepositoryReturns();
          sut = PlayerFilterCubit(
            playingLevelRepository: playingLevelRepository,
          );
        },
        build: () => sut,
        act: (cubit) => cubit.loadPlayingLevels(),
        expect: () => [
          HasLoadingStatus(LoadingStatus.loading),
          HasLoadingStatus(LoadingStatus.done),
        ],
        verify: (cubit) => expect(cubit.state.allPlayingLevels, playingLevels),
      );
    },
  );

  group(
    'PlayerFilterCubit age filter',
    () {
      var agedPlayers = [3, 14, 20, 40, 80].map((age) {
        var today = DateTime.now();
        var dateOfBirth = DateTime(today.year - age, today.month, today.day);
        return Player.newPlayer.copyWith(dateOfBirth: dateOfBirth);
      }).toList();

      setUp(() {
        arrangePlayingLevelRepositoryReturns();
        sut = PlayerFilterCubit(playingLevelRepository: playingLevelRepository);
      });

      test('initial age values are empty strings', () {
        expect(
          sut.state,
          allOf(HasAge('', over: true), HasAge('', over: false)),
        );
      });

      blocTest<PlayerFilterCubit, PlayerFilterState>(
        'emits age values that are put in.',
        build: () => sut,
        act: (cubit) {
          cubit.overAgeChanged('42');
          cubit.underAgeChanged('75');
          cubit.overAgeChanged('5');
          cubit.underAgeChanged('23');
        },
        expect: () => [
          HasAge('42', over: true),
          allOf(HasAge('42', over: true), HasAge('75', over: false)),
          allOf(HasAge('5', over: true), HasAge('75', over: false)),
          allOf(HasAge('5', over: true), HasAge('23', over: false)),
        ],
      );

      blocTest<PlayerFilterCubit, PlayerFilterState>(
        'only emits FilterPredicate for valid submitted age inputs',
        build: () => sut,
        act: (cubit) {
          cubit.overAgeChanged('-42');
          cubit.underAgeChanged('150');
          cubit.ageFilterSubmitted();
          cubit.underAgeChanged('xyz');
          cubit.overAgeChanged('42');
          cubit.ageFilterSubmitted();
        },
        expect: () => [
          HasAge('-42', over: true),
          HasAge('150', over: false),
          // No FilterPredicates emitted after submit of invalid ages
          allOf(HasAge('xyz', over: false), HasFilterPredicate(isNull)),
          allOf(HasAge('42', over: true), HasFilterPredicate(isNull)),
          // Only one filter predicate emitted for the one valid age
          HasFilterPredicate(isNotNull),
        ],
      );

      blocTest<PlayerFilterCubit, PlayerFilterState>(
        """emit FilterPredicates with null as their function for empty
        age inputs,
        do not replay emitted FilterPredicates""",
        build: () => sut,
        act: (cubit) {
          cubit.overAgeChanged('5');
          cubit.underAgeChanged('');
          cubit.ageFilterSubmitted();
          cubit.underAgeChanged('7');
        },
        expect: () => [
          HasAge('5', over: true),
          HasAge('', over: false),
          // Emit FilterPredicate with function for the filled age input
          HasFilterPredicate(WithPredicateFunction(isNotNull)),
          // Emit FilterPredicate with null-function for the empty age input
          HasFilterPredicate(WithPredicateFunction(isNull)),
          // Don't emit the FilterPredicate again
          allOf(HasAge('7', over: false), HasFilterPredicate(isNull)),
        ],
      );

      blocTest<PlayerFilterCubit, PlayerFilterState>(
        'emitted FilterPredicates correctly filter players.',
        build: () => sut,
        act: (cubit) {
          cubit.overAgeChanged('14');
          cubit.underAgeChanged('40');
          cubit.ageFilterSubmitted();
          cubit.overAgeChanged('90');
          cubit.underAgeChanged('3');
          cubit.ageFilterSubmitted();
        },
        expect: () => [
          HasAge('14', over: true),
          HasAge('40', over: false),
          HasFilterPredicate(
            WhereFilterResult(agedPlayers.sublist(1, 5), items: agedPlayers),
          ),
          HasFilterPredicate(
            WhereFilterResult(agedPlayers.sublist(0, 3), items: agedPlayers),
          ),
          HasAge('90', over: true),
          HasAge('3', over: false),
          HasFilterPredicate(
            WhereFilterResult([], items: agedPlayers),
          ),
          HasFilterPredicate(
            WhereFilterResult([], items: agedPlayers),
          ),
        ],
      );
    },
  );

  group('PlayerFilterCubit gender filter', () {
    var femalePlayer = Player.newPlayer.copyWith(gender: Gender.female);
    var malePlayer = Player.newPlayer.copyWith(gender: Gender.male);

    setUp(() {
      arrangePlayingLevelRepositoryReturns();
      sut = PlayerFilterCubit(playingLevelRepository: playingLevelRepository);
    });

    test('initial gender is null', () {
      expect(sut.state, HasGender(isNull));
    });

    blocTest<PlayerFilterCubit, PlayerFilterState>(
      """emits the gender that is put in and resets to null when the same gender
      is input twice in a row""",
      build: () => sut,
      act: (cubit) {
        cubit.genderChanged(Gender.female);
        cubit.genderChanged(Gender.male);
        cubit.genderChanged(Gender.male);
      },
      expect: () => [
        HasGender(Gender.female),
        HasGender(Gender.male),
        HasGender(isNull),
      ],
    );

    blocTest<PlayerFilterCubit, PlayerFilterState>(
      """emits a FilterPredicate on change and does not re-emit an empty
      predicate""",
      build: () => sut,
      act: (cubit) {
        cubit.genderChanged(Gender.female);
        cubit.genderChanged(Gender.male);
        cubit.genderChanged(Gender.none);
        cubit.genderChanged(null);
        cubit.genderChanged(null);
        cubit.genderChanged(Gender.none);
      },
      expect: () => [
        HasFilterPredicate(WithPredicateFunction(isNotNull)),
        HasFilterPredicate(WithPredicateFunction(isNotNull)),
        HasFilterPredicate(WithPredicateFunction(isNull)),
      ],
    );

    blocTest<PlayerFilterCubit, PlayerFilterState>(
      'emitted FilterPredicates correctly filter players',
      build: () => sut,
      act: (cubit) {
        cubit.genderChanged(Gender.female);
        cubit.genderChanged(Gender.male);
      },
      expect: () => [
        HasFilterPredicate(
          WhereFilterResult([femalePlayer], items: [malePlayer, femalePlayer]),
        ),
        HasFilterPredicate(
          WhereFilterResult([malePlayer], items: [malePlayer, femalePlayer]),
        ),
      ],
    );
  });

  group('PlayerFilterCubit playing level filter', () {
    var level0Player =
        Player.newPlayer.copyWith(playingLevel: playingLevels[0]);
    var level1Player =
        Player.newPlayer.copyWith(playingLevel: playingLevels[1]);
    var level2Player =
        Player.newPlayer.copyWith(playingLevel: playingLevels[2]);

    setUp(() {
      arrangePlayingLevelRepositoryReturns();
      sut = PlayerFilterCubit(playingLevelRepository: playingLevelRepository);
    });

    test('initial playing level list is empty', () {
      expect(sut.state, HasPlayingLevels([]));
    });

    blocTest<PlayerFilterCubit, PlayerFilterState>(
      'emits the playing level list as the PlayingLevels are toggled',
      build: () => sut,
      act: (cubit) {
        cubit.playingLevelToggled(playingLevels[0]);
        cubit.playingLevelToggled(playingLevels[1]);
        cubit.playingLevelToggled(playingLevels[2]);
        cubit.playingLevelToggled(playingLevels[1]);
        cubit.playingLevelToggled(playingLevels[0]);
        cubit.playingLevelToggled(playingLevels[2]);
      },
      expect: () => [
        HasPlayingLevels([playingLevels[0]]),
        HasPlayingLevels([playingLevels[0], playingLevels[1]]),
        HasPlayingLevels(playingLevels),
        HasPlayingLevels([playingLevels[0], playingLevels[2]]),
        HasPlayingLevels([playingLevels[2]]),
        HasPlayingLevels([]),
      ],
    );

    blocTest<PlayerFilterCubit, PlayerFilterState>(
      """FilterPredicates are emitted with or without predicate function
      according to the PlayingLevel being toggled on or off""",
      build: () => sut,
      act: (cubit) {
        cubit.playingLevelToggled(playingLevels[0]);
        cubit.playingLevelToggled(playingLevels[0]);
        cubit.playingLevelToggled(playingLevels[0]);
        cubit.playingLevelToggled(playingLevels[1]);
        cubit.playingLevelToggled(playingLevels[1]);
        cubit.playingLevelToggled(playingLevels[0]);
      },
      expect: () => [
        HasFilterPredicate(WithPredicateFunction(isNotNull)),
        HasFilterPredicate(WithPredicateFunction(isNull)),
        HasFilterPredicate(WithPredicateFunction(isNotNull)),
        HasFilterPredicate(WithPredicateFunction(isNotNull)),
        HasFilterPredicate(WithPredicateFunction(isNull)),
        HasFilterPredicate(WithPredicateFunction(isNull)),
      ],
    );

    blocTest<PlayerFilterCubit, PlayerFilterState>(
      'emitted FilterPredicates correctly filter players',
      build: () => sut,
      act: (cubit) {
        cubit.playingLevelToggled(playingLevels[0]);
        cubit.playingLevelToggled(playingLevels[2]);
        cubit.playingLevelToggled(playingLevels[1]);
      },
      expect: () => [
        HasFilterPredicate(WhereFilterResult(
          [level0Player],
          items: [level0Player, level1Player, level2Player],
        )),
        HasFilterPredicate(WhereFilterResult(
          [level2Player],
          items: [level0Player, level1Player, level2Player],
        )),
        HasFilterPredicate(WhereFilterResult(
          [level1Player],
          items: [level0Player, level1Player, level2Player],
        )),
      ],
    );
  });

  group('PlayerFilterCubit competition filter', () {
    var singles = Competition(
      id: 'singles',
      created: DateTime(2023),
      updated: DateTime(2023),
      teamSize: 1,
      gender: GenderCategory.any,
      ageRestriction: AgeRestriction.none,
      minLevel: PlayingLevel.unrated,
      maxLevel: PlayingLevel.unrated,
      registrations: const [],
    );
    var mixed = Competition(
      id: 'mixed',
      created: DateTime(2023),
      updated: DateTime(2023),
      teamSize: 2,
      gender: GenderCategory.mixed,
      ageRestriction: AgeRestriction.none,
      minLevel: PlayingLevel.unrated,
      maxLevel: PlayingLevel.unrated,
      registrations: const [],
    );
    var doubles = Competition(
      id: 'doubles',
      created: DateTime(2023),
      updated: DateTime(2023),
      teamSize: 2,
      gender: GenderCategory.female,
      ageRestriction: AgeRestriction.none,
      minLevel: PlayingLevel.unrated,
      maxLevel: PlayingLevel.unrated,
      registrations: const [],
    );
    var other = Competition(
      id: 'other',
      created: DateTime(2023),
      updated: DateTime(2023),
      teamSize: 4,
      gender: GenderCategory.any,
      ageRestriction: AgeRestriction.none,
      minLevel: PlayingLevel.unrated,
      maxLevel: PlayingLevel.unrated,
      registrations: const [],
    );

    setUp(() {
      arrangePlayingLevelRepositoryReturns();
      sut = PlayerFilterCubit(playingLevelRepository: playingLevelRepository);
    });

    test('initial ComeptitionType list is empty', () {
      expect(sut.state, HasCompetitionTypes([]));
    });

    blocTest<PlayerFilterCubit, PlayerFilterState>(
      'emits the competition type list as the CompetitionTypes are toggled',
      build: () => sut,
      act: (cubit) {
        cubit.competitionTypeToggled(CompetitionType.doubles);
        cubit.competitionTypeToggled(CompetitionType.mixed);
        cubit.competitionTypeToggled(CompetitionType.singles);
        cubit.competitionTypeToggled(CompetitionType.other);
        cubit.competitionTypeToggled(CompetitionType.mixed);
        cubit.competitionTypeToggled(CompetitionType.doubles);
        cubit.competitionTypeToggled(CompetitionType.other);
        cubit.competitionTypeToggled(CompetitionType.singles);
      },
      expect: () => [
        HasCompetitionTypes([
          CompetitionType.doubles,
        ]),
        HasCompetitionTypes([
          CompetitionType.doubles,
          CompetitionType.mixed,
        ]),
        HasCompetitionTypes([
          CompetitionType.doubles,
          CompetitionType.mixed,
          CompetitionType.singles,
        ]),
        HasCompetitionTypes([
          CompetitionType.doubles,
          CompetitionType.mixed,
          CompetitionType.singles,
          CompetitionType.other,
        ]),
        HasCompetitionTypes([
          CompetitionType.doubles,
          CompetitionType.singles,
          CompetitionType.other,
        ]),
        HasCompetitionTypes([
          CompetitionType.singles,
          CompetitionType.other,
        ]),
        HasCompetitionTypes([
          CompetitionType.singles,
        ]),
        HasCompetitionTypes([]),
      ],
    );
    blocTest<PlayerFilterCubit, PlayerFilterState>(
      """FilterPredicates are emitted with or without predicate function
      according to the CompetitionType being toggled on or off""",
      build: () => sut,
      act: (cubit) {
        cubit.competitionTypeToggled(CompetitionType.doubles);
        cubit.competitionTypeToggled(CompetitionType.doubles);
        cubit.competitionTypeToggled(CompetitionType.doubles);
        cubit.competitionTypeToggled(CompetitionType.mixed);
        cubit.competitionTypeToggled(CompetitionType.doubles);
        cubit.competitionTypeToggled(CompetitionType.mixed);
      },
      expect: () => [
        HasFilterPredicate(WithPredicateFunction(isNotNull)),
        HasFilterPredicate(WithPredicateFunction(isNull)),
        HasFilterPredicate(WithPredicateFunction(isNotNull)),
        HasFilterPredicate(WithPredicateFunction(isNotNull)),
        HasFilterPredicate(WithPredicateFunction(isNull)),
        HasFilterPredicate(WithPredicateFunction(isNull)),
      ],
    );

    blocTest<PlayerFilterCubit, PlayerFilterState>(
      'emitted FilterPredicates correctly filter competitions',
      build: () => sut,
      act: (cubit) {
        cubit.competitionTypeToggled(CompetitionType.doubles);
        cubit.competitionTypeToggled(CompetitionType.singles);
        cubit.competitionTypeToggled(CompetitionType.other);
        cubit.competitionTypeToggled(CompetitionType.mixed);
      },
      expect: () => [
        HasFilterPredicate(WhereFilterResult(
          [doubles],
          items: [singles, mixed, doubles, other],
        )),
        HasFilterPredicate(WhereFilterResult(
          [singles],
          items: [singles, mixed, doubles, other],
        )),
        HasFilterPredicate(WhereFilterResult(
          [other],
          items: [singles, mixed, doubles, other],
        )),
        HasFilterPredicate(WhereFilterResult(
          [mixed],
          items: [singles, mixed, doubles, other],
        )),
      ],
    );
  });

  group('PlayerListCubit text search filter', () {
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
          (index, name) => Player.newPlayer.copyWith(
            firstName: name[0],
            lastName: name[1],
            club: namedClubs[index],
          ),
        )
        .toList();

    setUp(() {
      arrangePlayingLevelRepositoryReturns();
      sut = PlayerFilterCubit(playingLevelRepository: playingLevelRepository);
    });

    test('initial search term in empty string', () {
      expect(sut.state, HasSearchTerm(''));
    });

    blocTest<PlayerFilterCubit, PlayerFilterState>(
      'emits the search term that is put in',
      build: () => sut,
      act: (cubit) {
        cubit.searchTermChanged('a');
        cubit.searchTermChanged('aB');
        cubit.searchTermChanged(' aB!3 ');
        cubit.searchTermChanged(
          List<String>.generate(80, (_) => 'A').join(),
        );
      },
      expect: () => [
        HasSearchTerm('a'),
        HasSearchTerm('aB'),
        HasSearchTerm(' aB!3 '),
        HasSearchTerm(
          List<String>.generate(80, (_) => 'A').join(),
        ),
      ],
    );

    blocTest<PlayerFilterCubit, PlayerFilterState>(
      """emits FilterPredicates when the search term changes but stops at the
      character limit (playerSearchMaxLength),
      emits an empty FilterPredicate when an empty search term is entered""",
      build: () => sut,
      act: (cubit) {
        cubit.searchTermChanged('a');
        cubit.searchTermChanged('aB');
        cubit.searchTermChanged('');
        cubit.searchTermChanged('');
        cubit.searchTermChanged(
          List<String>.generate(playerSearchMaxLength, (_) => 'A').join(),
        );
        cubit.searchTermChanged(
          List<String>.generate(playerSearchMaxLength + 1, (_) => 'A').join(),
        );
      },
      expect: () => [
        HasFilterPredicate(WithPredicateFunction(isNotNull)),
        HasFilterPredicate(WithPredicateFunction(isNotNull)),
        HasFilterPredicate(WithPredicateFunction(isNull)),
        HasFilterPredicate(WithPredicateFunction(isNull)),
        HasFilterPredicate(WithPredicateFunction(isNotNull)),
        HasFilterPredicate(isNull),
      ],
    );

    blocTest<PlayerFilterCubit, PlayerFilterState>(
      """emitted FilterPredicates correctly filter players with case
      insensitivity and string trimming""",
      build: () => sut,
      act: (cubit) {
        cubit.searchTermChanged('g'); // search for non-existent name
        cubit.searchTermChanged('a'); // by club name
        cubit.searchTermChanged('e Y'); // by first and last name
        cubit.searchTermChanged('f'); // by first name
        cubit.searchTermChanged('x'); // by last name
        cubit.searchTermChanged('   X  '); // leading/trailing space
      },
      expect: () => [
        HasFilterPredicate(WhereFilterResult(
          [],
          items: namedPlayers,
        )),
        HasFilterPredicate(WhereFilterResult(
          [namedPlayers[0]],
          items: namedPlayers,
        )),
        HasFilterPredicate(WhereFilterResult(
          [namedPlayers[1]],
          items: namedPlayers,
        )),
        HasFilterPredicate(WhereFilterResult(
          [namedPlayers[2]],
          items: namedPlayers,
        )),
        HasFilterPredicate(WhereFilterResult(
          [namedPlayers[0]],
          items: namedPlayers,
        )),
        HasFilterPredicate(WhereFilterResult(
          [namedPlayers[0]],
          items: namedPlayers,
        )),
      ],
    );
  });

  group('PlayerFilterCubit FilterPredicate creation/removal', () {
    setUp(() {
      arrangePlayingLevelRepositoryReturns();
      sut = PlayerFilterCubit(playingLevelRepository: playingLevelRepository);
    });

    blocTest<PlayerFilterCubit, PlayerFilterState>(
      """emits an empty FilterPredicate of over-/under-age domain when
      an over-/under-age predicate is set to be removed,
      the emitted predicates have the correct type,domain and disjunction""",
      build: () => sut,
      act: (cubit) {
        cubit.overAgeChanged('20');
        cubit.underAgeChanged('xyz');
        cubit.ageFilterSubmitted();
        var overAgePredicate = cubit.state.filterPredicate!;
        expect(
          overAgePredicate,
          allOf(
            WithPredicateType(Player),
            WithPredicateDisjunction(isEmpty),
            WithPredicateDomain(PlayerFilterCubit.overAgeDomain),
          ),
        );
        cubit.predicateRemoved(overAgePredicate);
        cubit.underAgeChanged('35');
        cubit.ageFilterSubmitted();
        var underAgePredicate = cubit.state.filterPredicate!;
        expect(
          underAgePredicate,
          allOf(
            WithPredicateType(Player),
            WithPredicateDisjunction(isEmpty),
            WithPredicateDomain(PlayerFilterCubit.underAgeDomain),
          ),
        );
        cubit.predicateRemoved(underAgePredicate);
      },
      expect: () => [
        HasAge('20', over: true),
        HasAge('xyz', over: false),
        HasFilterPredicate(isNotNull),
        // Removal should set the age filter to empty string
        HasAge('', over: true),
        // Removal triggers emission of FilterPredicate with null-function
        // in over-age domain
        HasFilterPredicate(allOf(
          WithPredicateFunction(isNull),
          WithPredicateDomain(PlayerFilterCubit.overAgeDomain),
        )),
        HasAge('35', over: false),
        HasFilterPredicate(WithPredicateFunction(isNull)),
        HasFilterPredicate(WithPredicateFunction(isNotNull)),
        HasAge('', over: false),
        HasFilterPredicate(allOf(
          WithPredicateFunction(isNull),
          WithPredicateDomain(PlayerFilterCubit.underAgeDomain),
        )),
      ],
    );

    blocTest<PlayerFilterCubit, PlayerFilterState>(
      """emits an empty FilterPredicate of gender domain when
      a gender predicate is set to be removed,
      the emitted predicate has the correct type,domain and disjunction""",
      build: () => sut,
      act: (cubit) {
        cubit.genderChanged(Gender.female);
        var genderPredicate = cubit.state.filterPredicate!;
        expect(
          genderPredicate,
          allOf(
            WithPredicateType(Player),
            WithPredicateDisjunction(isEmpty),
            WithPredicateDomain(PlayerFilterCubit.genderDomain),
          ),
        );
        cubit.predicateRemoved(genderPredicate);
      },
      expect: () => [
        HasGender(Gender.female),
        allOf(
          HasGender(isNull),
          HasFilterPredicate(allOf(
            WithPredicateFunction(isNull),
            WithPredicateDomain(PlayerFilterCubit.genderDomain),
          )),
        ),
      ],
    );

    blocTest<PlayerFilterCubit, PlayerFilterState>(
      """emits an empty FilterPredicate of playing level domain when
      a playing level predicate is set to be removed,
      the emitted predicate has the correct type,domain and disjunction""",
      build: () => sut,
      act: (cubit) {
        cubit.playingLevelToggled(playingLevels[0]);
        var playingLevelPredicate = cubit.state.filterPredicate!;
        expect(
          playingLevelPredicate,
          allOf(
            WithPredicateType(Player),
            WithPredicateDisjunction(PlayerFilterCubit.playingLevelDisjunction),
            WithPredicateDomain(playingLevels[0]),
          ),
        );
        cubit.predicateRemoved(playingLevelPredicate);
      },
      expect: () => [
        HasPlayingLevels([playingLevels[0]]),
        allOf(
          HasPlayingLevels([]),
          HasFilterPredicate(allOf(
            WithPredicateFunction(isNull),
            WithPredicateDomain(playingLevels[0]),
          )),
        ),
      ],
    );

    blocTest<PlayerFilterCubit, PlayerFilterState>(
      """emits an empty FilterPredicate of competition domain when
      a competition predicate is set to be removed,
      the emitted predicate has the correct type,domain and disjunction""",
      build: () => sut,
      act: (cubit) {
        cubit.competitionTypeToggled(CompetitionType.doubles);
        var competitionPredicate = cubit.state.filterPredicate!;
        expect(
          competitionPredicate,
          allOf(
            WithPredicateType(Competition),
            WithPredicateDisjunction(PlayerFilterCubit.competitionDisjunction),
            WithPredicateDomain(CompetitionType.doubles),
          ),
        );
        cubit.predicateRemoved(competitionPredicate);
      },
      expect: () => [
        HasCompetitionTypes([CompetitionType.doubles]),
        allOf(
          HasCompetitionTypes([]),
          HasFilterPredicate(allOf(
            WithPredicateFunction(isNull),
            WithPredicateDomain(CompetitionType.doubles),
          )),
        ),
      ],
    );

    blocTest<PlayerFilterCubit, PlayerFilterState>(
      """emits an empty FilterPredicate of text search domain when
      a text search predicate is set to be removed,
      the emitted predicate has the correct type,domain and disjunction""",
      build: () => sut,
      act: (cubit) {
        cubit.searchTermChanged('who dis?');
        var searchPredicate = cubit.state.filterPredicate!;
        expect(
          searchPredicate,
          allOf(
            WithPredicateType(Player),
            WithPredicateDisjunction(isEmpty),
            WithPredicateDomain(PlayerFilterCubit.searchDomain),
          ),
        );
        cubit.predicateRemoved(searchPredicate);
      },
      expect: () => [
        HasSearchTerm('who dis?'),
        allOf(
          HasSearchTerm(''),
          HasFilterPredicate(allOf(
            WithPredicateFunction(isNull),
            WithPredicateDomain(PlayerFilterCubit.searchDomain),
          )),
        ),
      ],
    );
  });
}
