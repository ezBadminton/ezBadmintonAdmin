import 'package:bloc_test/bloc_test.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_editing/cubit/competition_adding_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/models/competition_category.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';

import '../../common_matchers/state_matchers.dart';

class HasSelectedCompetitionDisciplines extends CustomMatcher {
  HasSelectedCompetitionDisciplines(matcher)
      : super(
          'CompetitionAddingState with',
          'selected compeititon disciplines',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.competitionDisciplines;
}

class HasSelectedAgeGroups extends CustomMatcher {
  HasSelectedAgeGroups(matcher)
      : super(
          'CompetitionAddingState with',
          'selected age groups',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.ageGroups;
}

class HasSelectedPlayingLevels extends CustomMatcher {
  HasSelectedPlayingLevels(matcher)
      : super(
          'CompetitionAddingState with',
          'selected playing levels',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.playingLevels;
}

class HasDisabledCompetitionDisciplines extends CustomMatcher {
  HasDisabledCompetitionDisciplines(matcher)
      : super(
          'CompetitionAddingState with',
          'disabled compeititon disciplines',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.disabledCompetitionDisciplines;
}

class HasDisabledAgeGroups extends CustomMatcher {
  HasDisabledAgeGroups(matcher)
      : super(
          'CompetitionAddingState with',
          'disabled age groups',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.disabledAgeGroups;
}

class HasDisabledPlayingLevels extends CustomMatcher {
  HasDisabledPlayingLevels(matcher)
      : super(
          'CompetitionAddingState with',
          'disabled playing levels',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.disabledPlayingLevels;
}

List<AgeGroup> ageGroups = List.generate(
  3,
  (index) => AgeGroup.newAgeGroup(type: AgeGroupType.over, age: 10 + index)
      .copyWith(id: 'AgeGroup-$index'),
);

List<PlayingLevel> playingLevels = List.generate(
  3,
  (index) => PlayingLevel.newPlayingLevel('PlayingLevel($index)', index)
      .copyWith(id: 'PlayingLevel-$index'),
);

/// All possible competitions that can be in ageGroups[0]
List<Competition> ageGroup0Competitions = playingLevels
    .map((playingLevel) => CompetitionDiscipline.baseCompetitions.map(
          (discipline) => Competition.newCompetition(
            teamSize:
                discipline.competitionType == CompetitionType.singles ? 1 : 2,
            genderCategory: discipline.genderCategory,
            ageGroup: ageGroups[0],
            playingLevel: playingLevel,
          ).copyWith(
            id: 'AgeGroupComp-${playingLevel.id}-${discipline.toString()}',
          ),
        ))
    .expand((competitions) => competitions)
    .toList();

/// All possible competitions under the mixed discipline
List<Competition> mixedCompetitions = playingLevels
    .map((playingLevel) => ageGroups.map(
          (ageGroup) => Competition.newCompetition(
            teamSize: 2,
            genderCategory: GenderCategory.mixed,
            ageGroup: ageGroup,
            playingLevel: playingLevel,
          ).copyWith(
            id: 'MixedComp-${ageGroup.id}-${playingLevel.id}',
          ),
        ))
    .expand((competitions) => competitions)
    .toList();

void main() {
  late CollectionRepository<Competition> competitionRepository;
  late CollectionRepository<AgeGroup> ageGroupRepository;
  late CollectionRepository<PlayingLevel> playingLevelRepository;
  late CollectionRepository<Tournament> tournamentRepository;

  void arrangeRepositories({
    bool throwing = false,
    List<Competition> competitions = const [],
    List<AgeGroup> ageGroups = const [],
    List<PlayingLevel> playingLevels = const [],
    List<Team> teams = const [],
    bool useAgeGroups = true,
    bool usePlayingLevels = true,
  }) {
    competitionRepository = TestCollectionRepository(
      initialCollection: competitions,
      throwing: throwing,
    );
    ageGroupRepository = TestCollectionRepository(
      initialCollection: ageGroups,
      throwing: throwing,
    );
    playingLevelRepository = TestCollectionRepository(
      initialCollection: playingLevels,
      throwing: throwing,
    );

    Tournament tournament = Tournament(
      id: 'test-tournament',
      created: DateTime.now(),
      updated: DateTime.now(),
      title: 'Test Tournament!',
      useAgeGroups: useAgeGroups,
      usePlayingLevels: usePlayingLevels,
      dontReprintGameSheets: true,
      printQrCodes: true,
      playerRestTime: 20,
      queueMode: QueueMode.manual,
    );
    tournamentRepository = TestCollectionRepository(
      initialCollection: [tournament],
      throwing: throwing,
    );
  }

  CompetitionAddingCubit createSut() {
    return CompetitionAddingCubit(
      competitionRepository: competitionRepository,
      ageGroupRepository: ageGroupRepository,
      playingLevelRepository: playingLevelRepository,
      tournamentRepository: tournamentRepository,
    );
  }

  setUp(() {
    arrangeRepositories(
      ageGroups: ageGroups,
      playingLevels: playingLevels,
    );
  });

  group('CompetitionAddingCubit', () {
    test('initial state', () {
      CompetitionAddingCubit sut = createSut();
      expect(sut.state, HasLoadingStatus(LoadingStatus.loading));
      expect(sut.state, HasFormStatus(FormzSubmissionStatus.initial));
      // All base competitions are initially selected
      expect(
        sut.state,
        HasSelectedCompetitionDisciplines(
            CompetitionDiscipline.baseCompetitions),
      );
    });

    blocTest<CompetitionAddingCubit, CompetitionAddingState>(
      'toggle competition options',
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.competitionDisciplineToggled(CompetitionDiscipline.mensDoubles);
        cubit.competitionDisciplineToggled(CompetitionDiscipline.mensDoubles);
        cubit.ageGroupToggled(ageGroups.first);
        cubit.playingLevelToggled(playingLevels.first);
      },
      skip: 1,
      expect: () => [
        HasSelectedCompetitionDisciplines(
          isNot(contains(CompetitionDiscipline.mensDoubles)),
        ),
        HasSelectedCompetitionDisciplines(
          containsAll(CompetitionDiscipline.baseCompetitions),
        ),
        HasSelectedAgeGroups([ageGroups.first]),
        HasSelectedPlayingLevels([playingLevels.first]),
      ],
    );

    blocTest<CompetitionAddingCubit, CompetitionAddingState>(
      'category is disabled when all possible competitions already exist',
      setUp: () => arrangeRepositories(
        ageGroups: ageGroups,
        playingLevels: playingLevels,
        competitions: ageGroup0Competitions,
      ),
      build: createSut,
      expect: () => [
        allOf(
          HasDisabledAgeGroups([ageGroups[0]]),
          HasDisabledPlayingLevels(isEmpty),
          HasDisabledCompetitionDisciplines(isEmpty),
        ),
      ],
    );

    blocTest<CompetitionAddingCubit, CompetitionAddingState>(
      'discipline is disabled when all possible competitions already exist',
      setUp: () => arrangeRepositories(
        ageGroups: ageGroups,
        playingLevels: playingLevels,
        competitions: mixedCompetitions,
      ),
      build: createSut,
      expect: () => [
        allOf(
          HasDisabledAgeGroups(isEmpty),
          HasDisabledPlayingLevels(isEmpty),
          HasDisabledCompetitionDisciplines([CompetitionDiscipline.mixed]),
        ),
      ],
    );

    blocTest<CompetitionAddingCubit, CompetitionAddingState>(
      'category option is disabled when other option is selected where all combinations already exist',
      setUp: () {
        List<Competition> competitions = List.of(ageGroup0Competitions);
        competitions.removeWhere((c) => c.playingLevel == playingLevels.first);
        arrangeRepositories(
          ageGroups: ageGroups,
          playingLevels: playingLevels,
          competitions: competitions,
        );
      },
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.playingLevelToggled(playingLevels[0]);
        cubit.playingLevelToggled(playingLevels[1]);
      },
      expect: () => [
        allOf(
          HasDisabledAgeGroups(isEmpty),
          HasDisabledPlayingLevels(isEmpty),
          HasDisabledCompetitionDisciplines(isEmpty),
        ),
        allOf(
          HasDisabledAgeGroups(isEmpty),
          HasDisabledPlayingLevels(isEmpty),
          HasDisabledCompetitionDisciplines(isEmpty),
        ),
        allOf(
          HasDisabledAgeGroups([ageGroups[0]]),
          HasDisabledPlayingLevels(isEmpty),
          HasDisabledCompetitionDisciplines(isEmpty),
        ),
      ],
    );

    blocTest<CompetitionAddingCubit, CompetitionAddingState>(
      'discipline is disabled when category is selected where it already exists',
      setUp: () {
        List<Competition> competitions = List.of(mixedCompetitions);
        competitions.removeWhere(
          (c) =>
              c.ageGroup == ageGroups.first &&
              c.playingLevel == playingLevels.first,
        );
        arrangeRepositories(
          ageGroups: ageGroups,
          playingLevels: playingLevels,
          competitions: competitions,
        );
      },
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.ageGroupToggled(ageGroups[0]);
        cubit.playingLevelToggled(playingLevels[0]);
        cubit.ageGroupToggled(ageGroups[1]);
      },
      expect: () => [
        allOf(
          HasDisabledAgeGroups(isEmpty),
          HasDisabledPlayingLevels(isEmpty),
          HasDisabledCompetitionDisciplines(isEmpty),
        ),
        allOf(
          HasDisabledAgeGroups(isEmpty),
          HasDisabledPlayingLevels(isEmpty),
          HasDisabledCompetitionDisciplines(isEmpty),
        ),
        allOf(
          HasDisabledAgeGroups(isEmpty),
          HasDisabledPlayingLevels(isEmpty),
          HasDisabledCompetitionDisciplines(isEmpty),
        ),
        allOf(
          HasDisabledAgeGroups(isEmpty),
          HasDisabledPlayingLevels(isEmpty),
          HasDisabledCompetitionDisciplines([CompetitionDiscipline.mixed]),
          HasSelectedAgeGroups(isNot(contains([CompetitionDiscipline.mixed]))),
        ),
      ],
    );

    blocTest<CompetitionAddingCubit, CompetitionAddingState>(
      'submit form',
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.competitionDisciplineToggled(CompetitionDiscipline.mensSingles);
        cubit.competitionDisciplineToggled(CompetitionDiscipline.womensSingles);
        cubit.ageGroupToggled(ageGroups[0]);
        cubit.ageGroupToggled(ageGroups[1]);
        cubit.playingLevelToggled(playingLevels[0]);
        cubit.formSubmitted();
      },
      skip: 6,
      expect: () => [
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasFormStatus(FormzSubmissionStatus.success),
      ],
      verify: (_) async {
        List<Competition> collection = await competitionRepository.getList();
        Set<CompetitionDiscipline> disciplinesInNew = collection
            .map((c) => CompetitionDiscipline.fromCompetition(c))
            .toSet();
        Set<AgeGroup> ageGroupsInNew =
            collection.map((c) => c.ageGroup!).toSet();
        Set<PlayingLevel> playingLevelsInNew =
            collection.map((c) => c.playingLevel!).toSet();

        expect(
          disciplinesInNew,
          containsAll([
            CompetitionDiscipline.womensDoubles,
            CompetitionDiscipline.mensDoubles,
            CompetitionDiscipline.mixed,
          ]),
        );
        expect(ageGroupsInNew, containsAll([ageGroups[0], ageGroups[1]]));
        expect(playingLevelsInNew, [playingLevels[0]]);

        expect(
          collection,
          hasLength(
            disciplinesInNew.length *
                ageGroupsInNew.length *
                playingLevelsInNew.length,
          ),
        );
      },
    );
  });
}
