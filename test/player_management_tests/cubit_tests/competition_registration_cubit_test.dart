import 'package:bloc_test/bloc_test.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/models/competition_registration.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/competition_registration_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/competition_registration_state.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/models/registration_warning.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common_matchers/state_matchers.dart';

class IsInFormStep extends CustomMatcher {
  IsInFormStep(matcher)
      : super(
          'State of form stepper in step',
          'step index',
          matcher,
        );
  @override
  featureValueOf(actual) => (actual as CompetitionRegistrationState).formStep;
}

class HasPartnerInput extends CustomMatcher {
  HasPartnerInput(matcher)
      : super(
          'State partner Player',
          'partner Player',
          matcher,
        );
  @override
  featureValueOf(actual) =>
      (actual as CompetitionRegistrationState).partner.value;
}

class HasCompetition extends CustomMatcher {
  HasCompetition(matcher)
      : super(
          'State with selected Competition of',
          'selected Competition',
          matcher,
        );
  @override
  featureValueOf(actual) =>
      (actual as CompetitionRegistrationState).competition.value;
}

class HasWarnings extends CustomMatcher {
  HasWarnings(matcher)
      : super(
          'State with registration warnings',
          'RegistrationWarning List',
          matcher,
        );
  @override
  featureValueOf(actual) => (actual as CompetitionRegistrationState).warnings;
}

var playingLevel = PlayingLevel(
  id: 'playingLevelId',
  created: DateTime.now(),
  updated: DateTime.now(),
  name: 'pretty good',
  index: 0,
);
var playingLevel2 = PlayingLevel(
  id: 'playingLevel2Id',
  created: DateTime.now(),
  updated: DateTime.now(),
  name: 'even better',
  index: 1,
);
var ageGroup = AgeGroup(
  id: 'ageGroupId',
  created: DateTime.now(),
  updated: DateTime.now(),
  age: 19,
  type: AgeGroupType.over,
);
var ageGroup2 = AgeGroup(
  id: 'ageGroup2Id',
  created: DateTime.now(),
  updated: DateTime.now(),
  age: 22,
  type: AgeGroupType.over,
);
var competitionWithPlayingLevel = Competition.newCompetition(
  teamSize: 2,
  genderCategory: GenderCategory.mixed,
).copyWith(
  id: 'comp0',
  playingLevel: playingLevel,
);
var competitionWithPlayingLevelAndAgeGroup = Competition.newCompetition(
  teamSize: 2,
  genderCategory: GenderCategory.mixed,
).copyWith(
  id: 'comp1',
  ageGroup: ageGroup,
  playingLevel: playingLevel,
);
var competitionWithPlayingLevelAndAgeGroup2 = Competition.newCompetition(
  teamSize: 1,
  genderCategory: GenderCategory.female,
).copyWith(
  id: 'comp2',
  ageGroup: ageGroup2,
  playingLevel: playingLevel2,
);
var competitionWithPlayingLevelAndAgeGroup3 = Competition.newCompetition(
  teamSize: 1,
  genderCategory: GenderCategory.male,
).copyWith(
  id: 'comp3',
  ageGroup: ageGroup,
  playingLevel: playingLevel2,
);

void main() {
  late CollectionRepository<Player> playerRepository;
  late CollectionRepository<Competition> competitionRepository;
  late CollectionRepository<AgeGroup> ageGroupRepository;
  late Player player;
  late List<CompetitionRegistration> registrations;

  CompetitionRegistrationCubit createSut() {
    return CompetitionRegistrationCubit(
      player: player,
      registrations: registrations,
      playerRepository: playerRepository,
      competitionRepository: competitionRepository,
      ageGroupRepository: ageGroupRepository,
    );
  }

  void arrangeRepositories({
    List<Player> players = const [],
    List<Competition> competitions = const [],
    List<AgeGroup> ageGroups = const [],
  }) {
    playerRepository = TestCollectionRepository(
      initialCollection: players,
    );
    competitionRepository = TestCollectionRepository(
      initialCollection: competitions,
    );
    ageGroupRepository = TestCollectionRepository(
      initialCollection: ageGroups,
    );
  }

  void arrangeRepositoryThrows() {
    playerRepository = TestCollectionRepository(throwing: true);
  }

  setUp(() {
    player = Player.newPlayer();

    registrations = [];

    arrangeRepositories();
  });

  group('CompetitionRegistrationCubit', () {
    test("""initial state has LoadingStatus.loading,
    inital form step is 0""", () {
      var sut = createSut();
      expect(sut.state, HasLoadingStatus(LoadingStatus.loading));
      expect(sut.state, IsInFormStep(0));
    });

    blocTest<CompetitionRegistrationCubit, CompetitionRegistrationState>(
      'emits LoadingStatus.failed when a repository throws',
      setUp: arrangeRepositoryThrows,
      build: createSut,
      expect: () => [HasLoadingStatus(LoadingStatus.failed)],
    );

    blocTest<CompetitionRegistrationCubit, CompetitionRegistrationState>(
      'goes back to LoadingStatus.loading when calling loadPlayerData()',
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

    blocTest<CompetitionRegistrationCubit, CompetitionRegistrationState>(
      """emits LoadingStatus.done after loading collections,
      the form steps contain the two mandatory competition parameter steps""",
      build: createSut,
      expect: () => [HasLoadingStatus(LoadingStatus.done)],
      verify: (cubit) {
        // The mandatory competition type and submission step
        expect(cubit.allFormSteps, hasLength(2));
        expect(cubit.lastFormStep, 1);
      },
    );

    blocTest<CompetitionRegistrationCubit, CompetitionRegistrationState>(
      """the form steps include a PlayingLevel step when a Competition
      with PlayingLevel parameter is available""",
      setUp: () {
        arrangeRepositories(
          competitions: [competitionWithPlayingLevel],
        );
      },
      build: createSut,
      verify: (cubit) {
        expect(cubit.allFormSteps, hasLength(2 + 1));
        expect(
          cubit.allFormSteps.expand((step) => step),
          contains(PlayingLevel),
        );
        expect(cubit.lastFormStep, 2);
      },
    );

    blocTest<CompetitionRegistrationCubit, CompetitionRegistrationState>(
      """the form steps include a PlayingLevel and AgeGroup step when a
      Competition with PlayingLevel/AgeGroup parameter is available""",
      setUp: () {
        arrangeRepositories(
          competitions: [competitionWithPlayingLevelAndAgeGroup],
        );
      },
      build: createSut,
      verify: (cubit) {
        expect(cubit.allFormSteps, hasLength(2 + 2));
        expect(
          cubit.allFormSteps.expand((step) => step),
          allOf(contains(PlayingLevel), contains(AgeGroup)),
        );
        expect(cubit.lastFormStep, 3);
      },
    );

    blocTest<CompetitionRegistrationCubit, CompetitionRegistrationState>(
      """getParameterOptions() returns the available options from the present
      Competitions""",
      setUp: () {
        arrangeRepositories(
          competitions: [
            competitionWithPlayingLevelAndAgeGroup,
            competitionWithPlayingLevelAndAgeGroup2,
          ],
        );
      },
      build: createSut,
      verify: (cubit) {
        expect(cubit.getParameterOptions<PlayingLevel>(), hasLength(2));
        expect(
          cubit.getParameterOptions<PlayingLevel>(),
          containsAll([playingLevel, playingLevel2]),
        );
        expect(cubit.getParameterOptions<AgeGroup>(), hasLength(2));
        expect(
          cubit.getParameterOptions<AgeGroup>(),
          containsAll([ageGroup, ageGroup2]),
        );
        expect(cubit.getParameterOptions<GenderCategory>(), hasLength(2));
        expect(
          cubit.getParameterOptions<GenderCategory>(),
          containsAll([GenderCategory.mixed, GenderCategory.female]),
        );
        expect(cubit.getParameterOptions<CompetitionType>(), hasLength(2));
        expect(
          cubit.getParameterOptions<CompetitionType>(),
          containsAll([CompetitionType.mixed, CompetitionType.singles]),
        );
        // Passing a type that is not a competition parameter
        expect(() => cubit.getParameterOptions<String>(), throwsAssertionError);
      },
    );

    blocTest<CompetitionRegistrationCubit, CompetitionRegistrationState>(
      """getParameterOptions(inSelection: true) returns the available options
      from the selected Competitions""",
      setUp: () {
        arrangeRepositories(
          competitions: [
            competitionWithPlayingLevelAndAgeGroup,
            competitionWithPlayingLevelAndAgeGroup2,
            competitionWithPlayingLevelAndAgeGroup3,
          ],
        );
      },
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.competitionParameterChanged<PlayingLevel>(playingLevel2);
      },
      verify: (cubit) {
        expect(
          cubit.getParameterOptions<PlayingLevel>(inSelection: true),
          hasLength(2),
        );
        expect(
          cubit.getParameterOptions<PlayingLevel>(),
          containsAll([playingLevel, playingLevel2]),
        );
        expect(
          cubit.getParameterOptions<AgeGroup>(inSelection: true),
          hasLength(2),
        );
        expect(
          cubit.getParameterOptions<AgeGroup>(),
          containsAll([ageGroup, ageGroup2]),
        );
        expect(
          cubit.getParameterOptions<GenderCategory>(inSelection: true),
          hasLength(2),
        );
        expect(
          cubit.getParameterOptions<GenderCategory>(),
          containsAll([GenderCategory.male, GenderCategory.female]),
        );
        expect(
          cubit.getParameterOptions<CompetitionType>(inSelection: true),
          hasLength(1),
        );
        expect(
          cubit.getParameterOptions<CompetitionType>(inSelection: true),
          containsAll([CompetitionType.singles]),
        );
      },
    );

    blocTest<CompetitionRegistrationCubit, CompetitionRegistrationState>(
      """competition parameter changes cause the form to step forward,
      setting CompetitionType.mixed also sets GenderCategory.mixed,
      setting GenderCategory.mixed also sets CompetitionType.mixed""",
      setUp: () {
        arrangeRepositories(
          competitions: [
            competitionWithPlayingLevelAndAgeGroup,
            competitionWithPlayingLevelAndAgeGroup2,
            competitionWithPlayingLevelAndAgeGroup3,
          ],
        );
      },
      build: createSut,
      skip: 1,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.competitionParameterChanged<PlayingLevel>(playingLevel);
        cubit.competitionParameterChanged<AgeGroup>(ageGroup);
        cubit.competitionParameterChanged<GenderCategory>(
          GenderCategory.female,
        );
        cubit.competitionParameterChanged<CompetitionType>(
          CompetitionType.singles,
        );

        cubit.competitionParameterChanged<CompetitionType>(
          CompetitionType.mixed,
        );

        cubit.competitionParameterChanged<CompetitionType>(
          CompetitionType.singles,
        );
        cubit.competitionParameterChanged<GenderCategory>(
          GenderCategory.mixed,
        );
      },
      expect: () => [
        allOf(
          IsInFormStep(1),
          HasPlayingLevelInput(playingLevel),
        ),
        allOf(
          IsInFormStep(2),
          HasAgeGroupInput(ageGroup),
        ),
        allOf(
          IsInFormStep(2),
          HasGenderCategoryInput(GenderCategory.female),
        ),
        allOf(
          IsInFormStep(3),
          HasCompetitionTypeInput(CompetitionType.singles),
        ),
        allOf(
          HasGenderCategoryInput(GenderCategory.mixed),
          HasCompetitionTypeInput(CompetitionType.mixed),
        ),
        HasCompetitionTypeInput(CompetitionType.singles),
        allOf(
          HasGenderCategoryInput(GenderCategory.mixed),
          HasCompetitionTypeInput(CompetitionType.mixed),
        ),
      ],
    );

    blocTest<CompetitionRegistrationCubit, CompetitionRegistrationState>(
      'Partner and partner name changes emit new states',
      build: createSut,
      skip: 1,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.partnerChanged(player);
        cubit.resetFormStep(1);
      },
      expect: () => [
        HasPartnerInput(player),
        HasPartnerInput(isNull),
      ],
    );

    test(
      'getFormStepFromParameterType() returns the correct form step',
      () async {
        var sut = createSut();
        await Future.delayed(Duration.zero);
        expect(sut.getFormStepFromParameterType<GenderCategory>(), 0);
        expect(sut.getFormStepFromParameterType<CompetitionType>(), 0);
        expect(sut.getFormStepFromParameterType<Player>(), 1);
        expect(
          () => sut.getFormStepFromParameterType<String>(),
          throwsAssertionError,
        );
      },
    );

    blocTest<CompetitionRegistrationCubit, CompetitionRegistrationState>(
      """submitting the form without boiling the selection down to one
      Competition by setting Competition parameters throws assertion error,
      submitting successfully emits a state with the selected Competition""",
      setUp: () {
        arrangeRepositories(
          competitions: [
            competitionWithPlayingLevelAndAgeGroup,
            competitionWithPlayingLevelAndAgeGroup2,
            competitionWithPlayingLevelAndAgeGroup3,
          ],
        );
      },
      build: createSut,
      skip: 4,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        expect(() => cubit.formSubmitted(), throwsAssertionError);
        cubit.competitionParameterChanged<PlayingLevel>(playingLevel);
        cubit.competitionParameterChanged<AgeGroup>(ageGroup);
        cubit.competitionParameterChanged<GenderCategory>(GenderCategory.mixed);
        cubit.formSubmitted();
      },
      expect: () => [
        allOf(
          HasCompetition(competitionWithPlayingLevelAndAgeGroup),
          HasWarnings(isEmpty),
        ),
      ],
    );

    blocTest<CompetitionRegistrationCubit, CompetitionRegistrationState>(
      """submitting a Competition with parameters that don't match the Player
      triggers warnings,
      calling warningsDismissed(true) emits the same selected
      Competition but without warnings,
      calling warningsDismissed(false) emits no selected
      Competition and no warnings""",
      setUp: () {
        var today = DateTime.now();
        player = Player.newPlayer().copyWith(
          playingLevel: playingLevel,
          dateOfBirth: DateTime(today.year - 20, today.month, today.day),
        );
        var alreadyRegisteredCompetition =
            competitionWithPlayingLevelAndAgeGroup3.copyWith(
          registrations: [
            Team.newTeam(players: [player]),
          ],
        );
        arrangeRepositories(
          competitions: [
            competitionWithPlayingLevelAndAgeGroup,
            competitionWithPlayingLevelAndAgeGroup2,
            alreadyRegisteredCompetition,
          ],
          ageGroups: [ageGroup, ageGroup2],
        );
        registrations = [
          CompetitionRegistration.fromCompetition(
              competition: alreadyRegisteredCompetition, player: player),
        ];
      },
      build: createSut,
      skip: 5,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.competitionParameterChanged<PlayingLevel>(playingLevel2);
        cubit.competitionParameterChanged<AgeGroup>(ageGroup2);
        cubit.competitionParameterChanged<GenderCategory>(
          GenderCategory.female,
        );
        cubit.competitionParameterChanged<CompetitionType>(
          CompetitionType.singles,
        );
        cubit.formSubmitted();
        cubit.warningsDismissed(true);
        cubit.warningsDismissed(false);
      },
      expect: () => [
        allOf(
          HasCompetition(competitionWithPlayingLevelAndAgeGroup2),
          HasWarnings(containsAll([
            isA<PlayingLevelWarning>(),
            isA<AgeGroupWarning>(),
            isA<GenderWarning>(),
          ])),
        ),
        allOf(
          HasCompetition(competitionWithPlayingLevelAndAgeGroup2),
          HasWarnings(isEmpty),
        ),
        allOf(
          HasCompetition(isNull),
          HasWarnings(isEmpty),
        ),
      ],
    );

    blocTest<CompetitionRegistrationCubit, CompetitionRegistrationState>(
      """resetFormStep() emits a state with the step's parameter inputs
      set to null""",
      setUp: () {
        arrangeRepositories(
          competitions: [
            competitionWithPlayingLevelAndAgeGroup,
            competitionWithPlayingLevelAndAgeGroup2,
            competitionWithPlayingLevelAndAgeGroup3,
          ],
        );
      },
      build: createSut,
      skip: 5,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.competitionParameterChanged<PlayingLevel>(playingLevel2);
        cubit.competitionParameterChanged<AgeGroup>(ageGroup2);
        cubit.competitionParameterChanged<GenderCategory>(
          GenderCategory.female,
        );
        cubit.competitionParameterChanged<CompetitionType>(
          CompetitionType.singles,
        );
        cubit.resetFormStep(2);
        cubit.resetFormStep(1);
        cubit.resetFormStep(0);
      },
      expect: () => [
        allOf(
          HasGenderCategoryInput(isNull),
          HasCompetitionTypeInput(isNull),
        ),
        HasAgeGroupInput(isNull),
        HasPlayingLevelInput(isNull),
      ],
    );

    blocTest<CompetitionRegistrationCubit, CompetitionRegistrationState>(
      """formStepBack() and formStepBackTo() reset the form steps
      and decrements the form step""",
      setUp: () {
        arrangeRepositories(
          competitions: [
            competitionWithPlayingLevelAndAgeGroup,
            competitionWithPlayingLevelAndAgeGroup2,
            competitionWithPlayingLevelAndAgeGroup3,
          ],
        );
      },
      build: createSut,
      skip: 3,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.competitionParameterChanged<PlayingLevel>(playingLevel2);
        cubit.competitionParameterChanged<AgeGroup>(ageGroup2);
        cubit.competitionParameterChanged<GenderCategory>(
          GenderCategory.female,
        );
        cubit.formStepBack();
        cubit.formStepBackTo(0);
      },
      expect: () => [
        IsInFormStep(2),
        allOf(
          HasCompetitionTypeInput(isNull),
          HasGenderCategoryInput(isNull),
        ),
        HasAgeGroupInput(isNull),
        IsInFormStep(1),
        HasAgeGroupInput(isNull),
        HasPlayingLevelInput(isNull),
        IsInFormStep(0),
      ],
    );
  });
}
