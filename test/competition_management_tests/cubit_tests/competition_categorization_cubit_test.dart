// ignore_for_file: invalid_use_of_protected_member

import 'package:bloc_test/bloc_test.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_categorization_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_categorization_state.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';

import '../../common_matchers/model_matchers.dart';
import '../../common_matchers/state_matchers.dart';

class MockAppLocalizations extends Mock implements AppLocalizations {}

List<AgeGroup> ageGroups = [1, 2]
    .map(
      (age) => AgeGroup.newAgeGroup(type: AgeGroupType.over, age: age)
          .copyWith(id: 'ageGroup$age'),
    )
    .toList();

List<PlayingLevel> playingLevels = [0, 1]
    .map(
      (level) => PlayingLevel.newPlayingLevel('$level', level)
          .copyWith(id: 'playingLevel$level'),
    )
    .toList();

List<Competition> playingLevelCompetitions = [
  for (PlayingLevel playingLevel in playingLevels) ...[
    Competition.newCompetition(
      teamSize: 1,
      genderCategory: GenderCategory.female,
      playingLevel: playingLevel,
    ).copyWith(id: 'ws${playingLevel.id}'),
    Competition.newCompetition(
      teamSize: 1,
      genderCategory: GenderCategory.male,
      playingLevel: playingLevel,
    ).copyWith(id: 'ms${playingLevel.id}'),
  ],
];

List<Competition> ageGroupCompetitions = [
  for (AgeGroup ageGroup in ageGroups) ...[
    Competition.newCompetition(
      teamSize: 1,
      genderCategory: GenderCategory.female,
      ageGroup: ageGroup,
    ).copyWith(id: 'ws${ageGroup.id}'),
    Competition.newCompetition(
      teamSize: 1,
      genderCategory: GenderCategory.male,
      ageGroup: ageGroup,
    ).copyWith(id: 'ms${ageGroup.id}'),
  ],
];

List<Competition> doubleCategeorizedCompetitions = [
  for (AgeGroup ageGroup in ageGroups)
    for (PlayingLevel playingLevel in playingLevels) ...[
      Competition.newCompetition(
        teamSize: 1,
        genderCategory: GenderCategory.female,
        ageGroup: ageGroup,
        playingLevel: playingLevel,
      ).copyWith(id: 'ws${ageGroup.id}${playingLevel.id}'),
      Competition.newCompetition(
        teamSize: 1,
        genderCategory: GenderCategory.male,
        ageGroup: ageGroup,
        playingLevel: playingLevel,
      ).copyWith(id: 'ms${ageGroup.id}${playingLevel.id}'),
    ],
];

Team team1 = Team.newTeam(
  players: [Player.newPlayer().copyWith(id: 'player1')],
).copyWith(id: 'team1');
Team team2 = Team.newTeam(
  players: [Player.newPlayer().copyWith(id: 'player2')],
).copyWith(id: 'team2');

void main() {
  late AppLocalizations l10n;
  late CollectionRepository<Tournament> tournamentRepository;
  late CollectionRepository<Competition> competitionRepository;
  late CollectionRepository<AgeGroup> ageGroupRepository;
  late CollectionRepository<PlayingLevel> playingLevelRepository;
  late CollectionRepository<Team> teamRepository;

  CompetitionCategorizationCubit createSut() {
    return CompetitionCategorizationCubit(
      l10n: l10n,
      tournamentRepository: tournamentRepository,
      competitionRepository: competitionRepository,
      ageGroupRepository: ageGroupRepository,
      playingLevelRepository: playingLevelRepository,
      teamRepository: teamRepository,
    );
  }

  void arrangel10nMessages() {
    when(() => l10n.defaultPlayingLevel).thenReturn('placeholder-playinglevel');
  }

  void arrangeRepositories({
    bool throwing = false,
    bool useAgeGroups = true,
    bool usePlayingLevels = true,
    List<Competition> competitions = const [],
    List<AgeGroup> ageGroups = const [],
    List<PlayingLevel> playingLevels = const [],
    List<Team> teams = const [],
  }) {
    Tournament tournament = Tournament(
      id: 'tournament',
      created: DateTime.now(),
      updated: DateTime.now(),
      title: 'test!',
      useAgeGroups: useAgeGroups,
      usePlayingLevels: usePlayingLevels,
      dontReprintGameSheets: true,
      printQrCodes: true,
    );

    tournamentRepository = TestCollectionRepository<Tournament>(
      initialCollection: [tournament],
      throwing: throwing,
    );
    competitionRepository = TestCollectionRepository<Competition>(
      initialCollection: competitions,
      throwing: throwing,
    );
    ageGroupRepository = TestCollectionRepository<AgeGroup>(
      initialCollection: ageGroups,
      throwing: throwing,
    );
    playingLevelRepository = TestCollectionRepository<PlayingLevel>(
      initialCollection: playingLevels,
      throwing: throwing,
    );
    teamRepository = TestCollectionRepository<Team>(
      initialCollection: teams,
      throwing: throwing,
    );
  }

  void arrangeRegistration(Competition competition, Team team) {
    List<Team> registrations = List.of(competition.registrations)..add(team);
    competitionRepository
        .update(competition.copyWith(registrations: registrations));
  }

  setUp(() {
    l10n = MockAppLocalizations();

    arrangeRepositories();

    arrangel10nMessages();
  });

  group('CompetitionCategorizationCubit', () {
    test('intial state', () async {
      CompetitionCategorizationCubit sut = createSut();
      expect(sut.state, HasLoadingStatus(LoadingStatus.loading));
      expect(sut.state, HasFormStatus(FormzSubmissionStatus.initial));
      await Future.delayed(Duration.zero);
      expect(competitionRepository.updateStreamController.hasListener, isTrue);
      expect(ageGroupRepository.updateStreamController.hasListener, isTrue);
      expect(playingLevelRepository.updateStreamController.hasListener, isTrue);
    });

    blocTest<CompetitionCategorizationCubit, CompetitionCategorizationState>(
      'loading status when repository throws',
      setUp: () => arrangeRepositories(
        throwing: true,
        useAgeGroups: false,
        usePlayingLevels: false,
      ),
      build: createSut,
      expect: () => [HasLoadingStatus(LoadingStatus.failed)],
    );

    blocTest<CompetitionCategorizationCubit, CompetitionCategorizationState>(
      'loading status',
      setUp: () => arrangeRepositories(
        useAgeGroups: false,
        usePlayingLevels: false,
      ),
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.loadCollections();
      },
      expect: () => [
        HasLoadingStatus(LoadingStatus.done),
        HasLoadingStatus(LoadingStatus.loading),
        HasLoadingStatus(LoadingStatus.done),
      ],
    );

    blocTest<CompetitionCategorizationCubit, CompetitionCategorizationState>(
      'set categorization of Tournament',
      setUp: () => arrangeRepositories(
        useAgeGroups: false,
        usePlayingLevels: false,
      ),
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.useAgeGroupsChanged(true);
        await Future.delayed(Duration.zero);
        cubit.usePlayingLevelsChanged(true);
      },
      skip: 1,
      expect: () => [
        HasFormStatus(FormzSubmissionStatus.inProgress),
        allOf(
          HasFormStatus(FormzSubmissionStatus.success),
          HasCollection<Tournament>(
            hasLength(1),
          ),
          HasCollection<Tournament>(
            contains(HasAgeGroupCategorization(isTrue)),
          ),
        ),
        HasFormStatus(FormzSubmissionStatus.inProgress),
        allOf(
          HasFormStatus(FormzSubmissionStatus.success),
          HasCollection<Tournament>(
            hasLength(1),
          ),
          HasCollection<Tournament>(
            contains(HasPlayingLevelCategorization(isTrue)),
          ),
        ),
      ],
    );

    blocTest<CompetitionCategorizationCubit, CompetitionCategorizationState>(
      'enable age groups with existing competitions',
      setUp: () => arrangeRepositories(
        useAgeGroups: false,
        playingLevels: playingLevels,
        competitions: playingLevelCompetitions,
      ),
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.useAgeGroupsChanged(true);
      },
      verify: (cubit) {
        expect(
          cubit.state,
          HasCollection<Competition>(everyElement(HasAgeGroup(isNotNull))),
        );
        expect(
          cubit.state,
          HasCollection<Competition>(playingLevelCompetitions),
        );
      },
    );

    blocTest<CompetitionCategorizationCubit, CompetitionCategorizationState>(
      'enable playingLevels with existing competitions',
      setUp: () => arrangeRepositories(
        usePlayingLevels: false,
        ageGroups: ageGroups,
        competitions: ageGroupCompetitions,
      ),
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.usePlayingLevelsChanged(true);
      },
      verify: (cubit) {
        expect(
          cubit.state,
          HasCollection<Competition>(everyElement(HasPlayingLevel(isNotNull))),
        );
        expect(
          cubit.state,
          HasCollection<Competition>(ageGroupCompetitions),
        );
      },
    );

    blocTest<CompetitionCategorizationCubit, CompetitionCategorizationState>(
      'disable age groups',
      setUp: () {
        arrangeRepositories(
          ageGroups: ageGroups,
          playingLevels: playingLevels,
          competitions: doubleCategeorizedCompetitions,
          teams: [team1],
        );
        arrangeRegistration(doubleCategeorizedCompetitions[0], team1);
      },
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.useAgeGroupsChanged(false);
      },
      verify: (cubit) {
        expect(
          cubit.state
              .getCollection<Competition>()
              .firstWhere((c) => c.registrations.isNotEmpty),
          HasRegistrations([team1]),
        );
        expect(
          cubit.state,
          HasCollection<Competition>(hasLength(4)),
        );
        expect(
          cubit.state,
          HasCollection<Competition>(everyElement(HasAgeGroup(isNull))),
        );
      },
    );

    blocTest<CompetitionCategorizationCubit, CompetitionCategorizationState>(
      'disable playing levels',
      setUp: () {
        arrangeRepositories(
          ageGroups: ageGroups,
          playingLevels: playingLevels,
          competitions: doubleCategeorizedCompetitions,
          teams: [team1],
        );
        arrangeRegistration(doubleCategeorizedCompetitions[0], team1);
      },
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.usePlayingLevelsChanged(false);
      },
      verify: (cubit) {
        expect(
          cubit.state
              .getCollection<Competition>()
              .firstWhere((c) => c.registrations.isNotEmpty),
          HasRegistrations([team1]),
        );
        expect(
          cubit.state,
          HasCollection<Competition>(hasLength(4)),
        );
        expect(
          cubit.state,
          HasCollection<Competition>(everyElement(HasPlayingLevel(isNull))),
        );
      },
    );

    blocTest<CompetitionCategorizationCubit, CompetitionCategorizationState>(
      'disable age groups with registration merge',
      setUp: () {
        arrangeRepositories(
          ageGroups: ageGroups,
          playingLevels: playingLevels,
          competitions: doubleCategeorizedCompetitions,
          teams: [team1, team2],
        );
        arrangeRegistration(doubleCategeorizedCompetitions[0], team1);
        arrangeRegistration(doubleCategeorizedCompetitions[4], team2);
      },
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.useAgeGroupsChanged(false);
        cubit.state.dialog.decisionCompleter!.complete(true);
      },
      verify: (cubit) {
        expect(
          cubit.state
              .getCollection<Competition>()
              .firstWhere((c) => c.registrations.isNotEmpty),
          HasRegistrations([team1, team2]),
        );
        expect(
          cubit.state,
          HasCollection<Competition>(hasLength(4)),
        );
        expect(
          cubit.state,
          HasCollection<Competition>(everyElement(HasAgeGroup(isNull))),
        );
      },
    );

    blocTest<CompetitionCategorizationCubit, CompetitionCategorizationState>(
      'disable playing levels with registration merge',
      setUp: () {
        arrangeRepositories(
          ageGroups: ageGroups,
          playingLevels: playingLevels,
          competitions: doubleCategeorizedCompetitions,
          teams: [team1, team2],
        );
        arrangeRegistration(doubleCategeorizedCompetitions[0], team1);
        arrangeRegistration(doubleCategeorizedCompetitions[2], team2);
      },
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.usePlayingLevelsChanged(false);
        cubit.state.dialog.decisionCompleter!.complete(true);
      },
      verify: (cubit) {
        expect(
          cubit.state
              .getCollection<Competition>()
              .firstWhere((c) => c.registrations.isNotEmpty),
          HasRegistrations([team1, team2]),
        );
        expect(
          cubit.state,
          HasCollection<Competition>(hasLength(4)),
        );
        expect(
          cubit.state,
          HasCollection<Competition>(everyElement(HasPlayingLevel(isNull))),
        );
      },
    );

    blocTest<CompetitionCategorizationCubit, CompetitionCategorizationState>(
      'deleting last age group disables age group categorization',
      setUp: () {
        arrangeRepositories(
          ageGroups: [ageGroups[0]],
          playingLevels: playingLevels,
        );
      },
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        ageGroupRepository.delete(ageGroups[0]);
      },
      skip: 1,
      expect: () => [
        HasLoadingStatus(LoadingStatus.loading),
        allOf(
          HasLoadingStatus(LoadingStatus.done),
          HasCollection<AgeGroup>(isEmpty),
        ),
        allOf(
          HasFormStatus(FormzSubmissionStatus.inProgress),
          HasCollection<Tournament>([HasAgeGroupCategorization(isTrue)]),
        ),
        allOf(
          HasFormStatus(FormzSubmissionStatus.success),
          HasCollection<Tournament>([HasAgeGroupCategorization(isFalse)]),
        ),
      ],
    );
  });
}
