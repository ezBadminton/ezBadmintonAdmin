import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_filter/competition_filter.dart';
import 'package:ez_badminton_admin_app/predicate_filter/common_predicate_producers/agegroup_predicate_producer.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/filter_predicate.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/predicate_producer.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate_producers.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../common_matchers/predicate_matchers.dart';
import '../../common_matchers/state_matchers.dart';

class MockAgeGroupPredicateProducer extends Mock
    implements AgeGroupPredicateProducer {}

class MockPlayingLevelPredicateProducer extends Mock
    implements PlayingLevelPredicateProducer {}

class MockRegistrationCountPredicateProducer extends Mock
    implements RegistrationCountPredicateProducer {}

class MockCompetitionTypePredicateProducer extends Mock
    implements CompetitionTypePredicateProducer {}

class MockGenderCategoryPredicateProducer extends Mock
    implements GenderCategoryPredicateProducer {}

void main() {
  var predicateProducerStreamController = StreamController<FilterPredicate>();
  var testPredicate = FilterPredicate(
    (o) => false,
    Competition,
    '',
    'testdomain',
  );

  late CollectionRepository<AgeGroup> ageGroupRepository;
  late CollectionRepository<PlayingLevel> playingLevelRepository;
  late CollectionRepository<Tournament> tournamentRepository;
  late AgeGroupPredicateProducer ageGroupPredicateProducer;
  late PlayingLevelPredicateProducer playingLevelPredicateProducer;
  late RegistrationCountPredicateProducer registrationCountPredicateProducer;
  late CompetitionTypePredicateProducer competitionTypePredicateProducer;
  late GenderCategoryPredicateProducer genderCategoryPredicateProducer;

  void arrangeRepositories() {
    ageGroupRepository = TestCollectionRepository<AgeGroup>();
    playingLevelRepository = TestCollectionRepository<PlayingLevel>();

    Tournament tournament = Tournament(
      id: 'tournament',
      created: DateTime.now(),
      updated: DateTime.now(),
      title: 'TestTournament',
      useAgeGroups: false,
      usePlayingLevels: false,
    );

    tournamentRepository = TestCollectionRepository<Tournament>(
      initialCollection: [tournament],
    );
  }

  void arrangePredicateProducers() {
    ageGroupPredicateProducer = MockAgeGroupPredicateProducer();
    playingLevelPredicateProducer = MockPlayingLevelPredicateProducer();
    registrationCountPredicateProducer =
        MockRegistrationCountPredicateProducer();
    competitionTypePredicateProducer = MockCompetitionTypePredicateProducer();
    genderCategoryPredicateProducer = MockGenderCategoryPredicateProducer();

    List<PredicateProducer> producers = [
      ageGroupPredicateProducer,
      playingLevelPredicateProducer,
      registrationCountPredicateProducer,
      competitionTypePredicateProducer,
      genderCategoryPredicateProducer,
    ];

    for (var producer in producers) {
      when(() => producer.predicateStream)
          .thenAnswer((_) => Stream<FilterPredicate>.fromIterable([]));
    }
  }

  CompetitionFilterCubit createSut() {
    return CompetitionFilterCubit(
      ageGroupRepository: ageGroupRepository,
      playingLevelRepository: playingLevelRepository,
      tournamentRepository: tournamentRepository,
      ageGroupPredicateProducer: ageGroupPredicateProducer,
      playingLevelPredicateProducer: playingLevelPredicateProducer,
      registrationCountPredicateProducer: registrationCountPredicateProducer,
      competitionTypePredicateProducer: competitionTypePredicateProducer,
      genderCategoryPredicateProducer: genderCategoryPredicateProducer,
    );
  }

  setUp(() {
    arrangeRepositories();
    arrangePredicateProducers();
  });

  group('CompetitionFilterCubit', () {
    test('initial state', () {
      CompetitionFilterCubit sut = createSut();
      expect(sut.state, HasLoadingStatus(LoadingStatus.loading));
      expect(sut.state, HasFilterPredicate(isNull));
    });

    blocTest<CompetitionFilterCubit, CompetitionFilterState>(
      'predicate consumption',
      setUp: () {
        when(() => ageGroupPredicateProducer.predicateStream)
            .thenAnswer((_) => predicateProducerStreamController.stream);
      },
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        predicateProducerStreamController.add(testPredicate);
      },
      skip: 1,
      expect: () => [
        HasFilterPredicate(HasDomain('testdomain')),
      ],
    );
  });
}
