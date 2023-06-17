import 'package:bloc_test/bloc_test.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/player_filter/player_filter.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/filter_predicate.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/predicate_producer.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../common_matchers/state_matchers.dart';

class MockCollectionRepository<M extends Model> extends Mock
    implements PocketbaseCollectionRepository<M> {}

class MockAgePredicateProducer extends Mock implements AgePredicateProducer {}

class MockGenderPredicateProducer extends Mock
    implements GenderCategoryPredicateProducer {}

class MockPlayingLevelPredicateProducer extends Mock
    implements PlayingLevelPredicateProducer {}

class MockCompetitionTypePredicateProducer extends Mock
    implements CompetitionTypePredicateProducer {}

class MockStatusPredicateProducer extends Mock
    implements StatusPredicateProducer {}

class MockSearchPredicateProducer extends Mock
    implements SearchPredicateProducer {}

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
  late PocketbaseCollectionRepository<PlayingLevel> playingLevelRepository;
  late PlayerFilterCubit sut;
  late List<PredicateProducer> producers;
  late AgePredicateProducer agePredicateProducer;
  late GenderCategoryPredicateProducer genderPredicateProducer;
  late PlayingLevelPredicateProducer playingLevelPredicateProducer;
  late CompetitionTypePredicateProducer competitionTypePredicateProducer;
  late StatusPredicateProducer statusPredicateProducer;
  late SearchPredicateProducer searchPredicateProducer;

  void arrangePlayingLevelRepositoryReturns() {
    when(
      () => playingLevelRepository.getList(expand: any(named: 'expand')),
    ).thenAnswer((_) async => playingLevels);
  }

  void arrangePlayingLevelRepositoryThrows() {
    when(
      () => playingLevelRepository.getList(expand: any(named: 'expand')),
    ).thenAnswer((_) async => throw CollectionQueryException('errorCode'));
  }

  void arrageProducersHaveStream() {
    for (var producer in producers) {
      when(() => producer.predicateStream)
          .thenAnswer((_) => Stream<FilterPredicate>.fromIterable([]));
    }
  }

  void arrageProducersCloseStream() {
    for (var producer in producers) {
      when(() => producer.close()).thenAnswer((_) async {});
    }
  }

  PlayerFilterCubit createSut() {
    return PlayerFilterCubit(
      playingLevelRepository: playingLevelRepository,
      agePredicateProducer: agePredicateProducer,
      genderPredicateProducer: genderPredicateProducer,
      playingLevelPredicateProducer: playingLevelPredicateProducer,
      competitionTypePredicateProducer: competitionTypePredicateProducer,
      statusPredicateProducer: statusPredicateProducer,
      searchPredicateProducer: searchPredicateProducer,
    );
  }

  setUp(() {
    playingLevelRepository = MockCollectionRepository();
    agePredicateProducer = MockAgePredicateProducer();
    genderPredicateProducer = MockGenderPredicateProducer();
    playingLevelPredicateProducer = MockPlayingLevelPredicateProducer();
    competitionTypePredicateProducer = MockCompetitionTypePredicateProducer();
    statusPredicateProducer = MockStatusPredicateProducer();
    searchPredicateProducer = MockSearchPredicateProducer();

    producers = [
      agePredicateProducer,
      genderPredicateProducer,
      playingLevelPredicateProducer,
      competitionTypePredicateProducer,
      statusPredicateProducer,
      searchPredicateProducer,
    ];

    arrageProducersHaveStream();
    arrageProducersCloseStream();
  });

  group(
    'PlayerFilterCubit initial state and loading',
    () {
      test('initial LoadingStatus is loading', () {
        arrangePlayingLevelRepositoryReturns();
        expect(
          createSut().state,
          HasLoadingStatus(LoadingStatus.loading),
        );
      });

      blocTest<PlayerFilterCubit, PlayerFilterState>(
        'emits LoadingStatus.failed when PlayingLevelRepository throws',
        setUp: () => arrangePlayingLevelRepositoryThrows(),
        build: () => createSut(),
        expect: () => [HasLoadingStatus(LoadingStatus.failed)],
      );

      blocTest<PlayerFilterCubit, PlayerFilterState>(
        """emits playing levels from PlayingLevelRepository
        and LoadingStatus.done when PlayingLevelRepository returns""",
        setUp: () => arrangePlayingLevelRepositoryReturns(),
        build: () => createSut(),
        expect: () => [HasLoadingStatus(LoadingStatus.done)],
        verify: (cubit) => expect(cubit.state.allPlayingLevels, playingLevels),
      );

      blocTest<PlayerFilterCubit, PlayerFilterState>(
        'goes back to LoadingStatus.loading when playing levels are reloaded',
        setUp: () {
          arrangePlayingLevelRepositoryReturns();
          sut = createSut();
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

  group('PlayerFilterCubit state emission', () {
    var filterPredicate =
        FilterPredicate((o) => false, Player, 'testname', 'testdomain');

    Future<FilterPredicate> futurePredicate() async {
      await Future.delayed(const Duration(milliseconds: 3));
      return filterPredicate;
    }

    setUp(() {
      when(() => agePredicateProducer.predicateStream).thenAnswer(
        (_) => Stream<FilterPredicate>.fromFuture(futurePredicate()),
      );

      arrangePlayingLevelRepositoryReturns();
    });

    blocTest<PlayerFilterCubit, PlayerFilterState>(
      'emits a state with the FilterPredicate when it is produced.',
      build: () => createSut(),
      skip: 1, // Skip LoadingStatus.done state
      wait: const Duration(milliseconds: 3),
      expect: () => [
        HasFilterPredicate(WithPredicateDomain('testdomain')),
      ],
    );
  });
}
