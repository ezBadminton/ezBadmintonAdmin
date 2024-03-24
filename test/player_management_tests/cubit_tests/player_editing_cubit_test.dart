// ignore_for_file: invalid_use_of_protected_member

import 'package:bloc_test/bloc_test.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/models/competition_registration.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/player_editing_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';

import '../../common_matchers/model_matchers.dart';
import '../../common_matchers/state_matchers.dart';

class MockBuildContext extends Mock implements BuildContext {}

class RegistrationFormShown extends CustomMatcher {
  RegistrationFormShown(matcher)
      : super(
          'State with registrationFormShown that is',
          'bool',
          matcher,
        );
  @override
  featureValueOf(actual) =>
      (actual as PlayerEditingState).registrationFormShown;
}

class HasCompetitionRegistrations extends CustomMatcher {
  HasCompetitionRegistrations(matcher)
      : super(
          'State with registrations',
          'CompetitionRegistration List',
          matcher,
        );
  @override
  featureValueOf(actual) => (actual as PlayerEditingState).registrations.value;
}

class HasCompetitionRegistration extends CustomMatcher {
  HasCompetitionRegistration(matcher, {this.index = 0})
      : super(
          'State with',
          'CompetitionRegistration (index $index)',
          matcher,
        );

  final int index;
  @override
  featureValueOf(actual) =>
      (actual as PlayerEditingState).registrations.value[index];
}

class WithCompetition extends CustomMatcher {
  WithCompetition(matcher)
      : super(
          'CompetitionRegistration with',
          'Competition',
          matcher,
        );

  @override
  featureValueOf(actual) => (actual as CompetitionRegistration).competition;
}

class WithPartner extends CustomMatcher {
  WithPartner(matcher, {required this.ofPlayer})
      : super(
          'CompetitionRegistration with',
          'partner',
          matcher,
        );
  final Player ofPlayer;
  @override
  featureValueOf(actual) => (actual as CompetitionRegistration).partner;
}

class TestPlayerEditingCubit extends PlayerEditingCubit {
  TestPlayerEditingCubit({
    required BuildContext context,
    Player? player,
    required CollectionRepository<Player> playerRepository,
    required CollectionRepository<Competition> competitionRepository,
    required CollectionRepository<Club> clubRepository,
    required CollectionRepository<PlayingLevel> playingLevelRepository,
    required CollectionRepository<Team> teamRepository,
    required CollectionRepository<Tournament> tournamentRepository,
  }) : super(
          player: player,
          playerRepository: playerRepository,
          competitionRepository: competitionRepository,
          clubRepository: clubRepository,
          playingLevelRepository: playingLevelRepository,
          teamRepository: teamRepository,
          tournamentRepository: tournamentRepository,
        );
}

void main() {
  late BuildContext context;
  late CollectionRepository<Player> playerRepository;
  late CollectionRepository<Competition> competitionRepository;
  late CollectionRepository<Club> clubRepository;
  late CollectionRepository<PlayingLevel> playingLevelRepository;
  late CollectionRepository<Team> teamRepository;
  late CollectionRepository<Tournament> tournamentRepository;

  var player = Player.newPlayer().copyWith(
    id: 'playerid',
    firstName: 'Kento',
    lastName: 'Momota',
    notes: 'x@d.de',
    club: Club.newClub(name: 'Cool Guys Club'),
  );

  var player2 = Player.newPlayer().copyWith(
    id: 'playerid2',
    firstName: 'Marcus',
    lastName: 'Gideon',
  );

  var competition = Competition.newCompetition(
    teamSize: 2,
    genderCategory: GenderCategory.any,
  ).copyWith(id: 'competitionid');

  PlayerEditingCubit createSut(Player? player) {
    return TestPlayerEditingCubit(
      player: player,
      context: context,
      playerRepository: playerRepository,
      competitionRepository: competitionRepository,
      clubRepository: clubRepository,
      playingLevelRepository: playingLevelRepository,
      teamRepository: teamRepository,
      tournamentRepository: tournamentRepository,
    );
  }

  setUpAll(() {
    registerFallbackValue(Player.newPlayer());
    registerFallbackValue(Club.newClub(name: 'fallback club'));
    registerFallbackValue(competition);
    registerFallbackValue(Team.newTeam());
  });

  void arrangeRepositories({
    List<Player> players = const [],
    List<Competition> competitions = const [],
    List<Club> clubs = const [],
    List<PlayingLevel> playingLevels = const [],
    List<Team> teams = const [],
  }) {
    playerRepository = TestCollectionRepository(
      initialCollection: players,
    );
    competitionRepository = TestCollectionRepository(
      initialCollection: competitions,
    );
    clubRepository = TestCollectionRepository(
      initialCollection: clubs,
    );
    playingLevelRepository = TestCollectionRepository(
      initialCollection: playingLevels,
    );
    teamRepository = TestCollectionRepository(
      initialCollection: teams,
    );
    tournamentRepository = TestCollectionRepository();
  }

  setUp(() {
    context = MockBuildContext();

    arrangeRepositories();
  });

  group('PlayerEditingCubit editing form', () {
    test('initial state', () async {
      var sut = createSut(null);
      expect(sut.state, HasLoadingStatus(LoadingStatus.loading));
      expect(sut.state, HasFormStatus(FormzSubmissionStatus.initial));
      expect(sut.state.player.id, isEmpty);
      await Future.delayed(Duration.zero);
      expect(teamRepository.updateStreamController.hasListener, isTrue);
      expect(competitionRepository.updateStreamController.hasListener, isTrue);
    });

    blocTest<PlayerEditingCubit, PlayerEditingState>(
      """first emitted state has LoadingStatus.done,
      copies given player's attributes to state""",
      build: () => createSut(player),
      expect: () => [
        allOf(
          HasLoadingStatus(LoadingStatus.done),
          HasFirstNameInput(player.firstName),
          HasLastNameInput(player.lastName),
          HasNotesInput(player.notes),
          HasClubNameInput(player.club!.name),
        ),
      ],
    );

    blocTest<PlayerEditingCubit, PlayerEditingState>(
      """value inputs are emitted as new states""",
      setUp: () {
        arrangeRepositories(competitions: [competition]);
      },
      build: () => createSut(null),
      skip: 1, // skip loading done state
      act: (cubit) async {
        cubit.firstNameChanged('changedFirstName');
        cubit.lastNameChanged('changedLastName');
        cubit.notesChanged('changedNotes');
        cubit.clubNameChanged('changedClubName');
        cubit.registrationFormOpened();
        await Future.delayed(Duration.zero);
        cubit.registrationCanceled();
      },
      expect: () => [
        HasFirstNameInput('changedFirstName'),
        HasLastNameInput('changedLastName'),
        HasNotesInput('changedNotes'),
        HasClubNameInput('changedClubName'),
        RegistrationFormShown(isTrue),
        RegistrationFormShown(isFalse),
      ],
    );

    blocTest<PlayerEditingCubit, PlayerEditingState>(
      """adding a registration creates CompetitionRegistration object
      with team of player and optional partner,
      removing registration emits reduced registration list""",
      build: () => createSut(player),
      skip: 1, // skip loading done state
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.registrationFormOpened();
        cubit.registrationAdded(competition, null);
        cubit.registrationFormOpened();
        cubit.registrationAdded(competition, player2);
        var registration = cubit.state.registrations.value[1];
        cubit.registrationRemoved(registration);
      },
      expect: () => [
        RegistrationFormShown(isTrue),
        HasCompetitionRegistration(
          allOf(
            HasPlayer(player),
            WithCompetition(competition),
            WithPartner(isNull, ofPlayer: player),
          ),
        ),
        RegistrationFormShown(isTrue),
        HasCompetitionRegistration(
          allOf(
            HasPlayer(player),
            WithCompetition(competition),
            WithPartner(player2, ofPlayer: player),
          ),
          index: 1,
        ),
        HasCompetitionRegistrations(hasLength(1)),
      ],
    );
  });

  group('PlayerEditingCubit form submit', () {
    void arrangePlayerRepositoryThrows() {
      playerRepository = TestCollectionRepository(throwing: true);
    }

    void arrangeTeamRepositoryThrows() {
      teamRepository = TestCollectionRepository(throwing: true);
    }

    blocTest<PlayerEditingCubit, PlayerEditingState>(
      """submission of invalid form inputs creates
      FormzSubmissionStatus.failure,
      valid form inputs lead to FormzSubmissionStatus.inProgress,
      then FormzSubmissionStatus.success""",
      setUp: () {
        arrangeRepositories(players: [player]);
      },
      build: () => createSut(player),
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 2));
        // Leave name input empty to create invalid form submission
        cubit.firstNameChanged('');
        cubit.formSubmitted();
        // Create valid form submission
        cubit.firstNameChanged('Alice');
        cubit.lastNameChanged('Smith');
        cubit.formSubmitted();
      },
      skip: 1, // skip loading done state
      expect: () => [
        HasFirstNameInput(isEmpty),
        HasFormStatus(FormzSubmissionStatus.failure),
        HasFirstNameInput(isNotEmpty),
        HasLastNameInput(isNotEmpty),
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasLoadingStatus(LoadingStatus.done),
        HasLoadingStatus(LoadingStatus.done),
        HasFormStatus(FormzSubmissionStatus.success),
      ],
    );

    blocTest<PlayerEditingCubit, PlayerEditingState>(
      """FormzSubmissionStatus.inProgress then FormzSubmissionStatus.failure is
      emitted when Player repository throws during create""",
      setUp: arrangePlayerRepositoryThrows,
      build: () => createSut(null),
      skip: 1, // skip loading failed state
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 2));
        cubit.firstNameChanged('Alice');
        cubit.lastNameChanged('Smith');
        cubit.formSubmitted();
      },
      expect: () => [
        HasFirstNameInput(isNotEmpty),
        HasLastNameInput(isNotEmpty),
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasFormStatus(FormzSubmissionStatus.failure),
      ],
    );

    blocTest<PlayerEditingCubit, PlayerEditingState>(
      """FormzSubmissionStatus.inProgress then FormzSubmissionStatus.failure is
      emitted when Team repository throws during update""",
      setUp: arrangeTeamRepositoryThrows,
      build: () => createSut(null),
      skip: 1, // skip loading failed state
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 2));
        cubit.firstNameChanged('Alice');
        cubit.lastNameChanged('Smith');
        cubit.registrationFormOpened();
        cubit.registrationAdded(competition, null);
        cubit.formSubmitted();
      },
      expect: () => [
        HasFirstNameInput(isNotEmpty),
        HasLastNameInput(isNotEmpty),
        RegistrationFormShown(isTrue),
        HasCompetitionRegistrations(hasLength(1)),
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasLoadingStatus(LoadingStatus.done),
        HasFormStatus(FormzSubmissionStatus.failure),
      ],
    );

    blocTest<PlayerEditingCubit, PlayerEditingState>(
      """value inputs are correctly applied to the Player object,
      a new Club is created with the given name""",
      build: () => createSut(null),
      skip: 5, // skip form input state changes
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 2));
        cubit.firstNameChanged('changedFirstName');
        cubit.lastNameChanged('changedLastName');
        cubit.notesChanged('changedEMail@example.com');
        cubit.clubNameChanged('changedClubName');
        cubit.formSubmitted();
      },
      expect: () => [
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasLoadingStatus(LoadingStatus.done),
        HasLoadingStatus(LoadingStatus.done),
        HasPlayer(allOf(
          HasFirstName('changedFirstName'),
          HasLastName('changedLastName'),
          HasNotes('changedEMail@example.com'),
          HasClub(HasName('changedClubName')),
        )),
      ],
      verify: (_) {
        List<Club> collection = clubRepository.getList();
        expect(collection, [HasName('changedClubName')]);
      },
    );

    blocTest<PlayerEditingCubit, PlayerEditingState>(
      """an existing Club is selected by name""",
      setUp: () {
        arrangeRepositories(clubs: [Club.newClub(name: 'existing club')]);
      },
      build: () => createSut(null),
      skip: 4, // skip form input state changes
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.firstNameChanged('changedFirstName');
        cubit.lastNameChanged('changedLastName');
        cubit.clubNameChanged('existing club');
        cubit.formSubmitted();
      },
      expect: () => [
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasLoadingStatus(LoadingStatus.done),
        HasPlayer(allOf(
          HasFirstName('changedFirstName'),
          HasLastName('changedLastName'),
          HasNotes(isEmpty),
          HasClub(HasName('existing club')),
        )),
      ],
      verify: (bloc) {
        List<Club> collection = clubRepository.getList();
        expect(collection, [HasName('existing club')]);
      },
    );

    final teamWithPartner =
        Team.newTeam(players: [player, player2]).copyWith(id: 'teamId');
    blocTest<PlayerEditingCubit, PlayerEditingState>(
      """deregistering from a Competition correctly updates the Comptetition's
      registrations List,
      the Team the edited Player was part of has the Player removed""",
      setUp: () {
        arrangeRepositories(
          teams: [teamWithPartner],
          competitions: [
            competition.copyWith(registrations: [teamWithPartner]),
          ],
          players: List.of(teamWithPartner.players),
        );
      },
      build: () => createSut(player),
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.registrationRemoved(cubit.state.registrations.value.first);
        cubit.formSubmitted();
      },
      verify: (bloc) {
        List<Competition> competitionCollection =
            competitionRepository.getList();
        List<Team> teamCollection = teamRepository.getList();
        expect(competitionCollection, hasLength(1));
        expect(competitionCollection.first.registrations, hasLength(1));
        expect(teamCollection, hasLength(1));
        expect(
          teamCollection.first.players,
          allOf(contains(player2), isNot(contains(player))),
        );
      },
    );
  });
}
