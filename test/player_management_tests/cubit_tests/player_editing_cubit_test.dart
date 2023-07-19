import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/models/competition_registration.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/player_editing_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';

import '../../common_matchers/model_matchers.dart';
import '../../common_matchers/state_matchers.dart';

class MockCollectionRepository<M extends Model> extends Mock
    implements PocketbaseCollectionRepository<M> {}

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
    super.player,
    required super.context,
    required super.playerRepository,
    required super.competitionRepository,
    required super.clubRepository,
    required super.playingLevelRepository,
    required super.teamRepository,
  });

  @override
  String Function(DateTime) get dateFormatter => DateFormat.yMd().format;

  @override
  DateTime Function(String) get dateParser => DateFormat.yMd().parse;
}

void main() {
  late BuildContext context;
  late CollectionRepository<Player> playerRepository;
  late CollectionRepository<Competition> competitionRepository;
  late CollectionRepository<Club> clubRepository;
  late CollectionRepository<PlayingLevel> playingLevelRepository;
  late CollectionRepository<Team> teamRepository;

  late List<Player> playerList;
  late List<Competition> competitionList;
  late List<Team> teamList;
  late List<Club> clubList;

  late StreamController<CollectionUpdateEvent<Team>> teamUpdateController;

  var playingLevel = PlayingLevel(
    id: 'playinglevelid',
    created: DateTime.now(),
    updated: DateTime.now(),
    name: 'good player',
    index: 0,
  );

  var player = Player.newPlayer().copyWith(
    id: 'playerid',
    firstName: 'Kento',
    lastName: 'Momota',
    notes: 'x@d.de',
    dateOfBirth: DateTime(2000),
    playingLevel: playingLevel,
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
    );
  }

  setUpAll(() {
    registerFallbackValue(Player.newPlayer());
    registerFallbackValue(Club.newClub(name: 'fallback club'));
    registerFallbackValue(competition);
    registerFallbackValue(Team.newTeam());
  });

  void arrangeRepositoriesReturn() {
    when(() => playerRepository.getList(expand: any(named: 'expand')))
        .thenAnswer((_) async => playerList);
    when(() => competitionRepository.getList(expand: any(named: 'expand')))
        .thenAnswer((_) async => competitionList);
    when(() =>
            competitionRepository.getModel(any(), expand: any(named: 'expand')))
        .thenAnswer((_) async => competitionList[0]);
    when(() => clubRepository.getList(expand: any(named: 'expand')))
        .thenAnswer((_) async => clubList);
    when(() => playingLevelRepository.getList(expand: any(named: 'expand')))
        .thenAnswer((_) async => <PlayingLevel>[]);
    when(() => teamRepository.getList(expand: any(named: 'expand')))
        .thenAnswer((_) async => teamList);
    when(() => teamRepository.updateStream)
        .thenAnswer((_) => teamUpdateController.stream);
  }

  void arrangeOneRepositoryThrows() {
    when(() => playerRepository.getList(expand: any(named: 'expand')))
        .thenAnswer((_) async => throw CollectionQueryException('420'));
  }

  setUp(() {
    context = MockBuildContext();
    playerRepository = MockCollectionRepository<Player>();
    competitionRepository = MockCollectionRepository<Competition>();
    clubRepository = MockCollectionRepository<Club>();
    playingLevelRepository = MockCollectionRepository<PlayingLevel>();
    teamRepository = MockCollectionRepository<Team>();

    teamUpdateController = StreamController.broadcast();

    playerList = [];
    competitionList = [];
    teamList = [];
    clubList = [];

    arrangeRepositoriesReturn();
  });

  group('PlayerEditingCubit editing form', () {
    test("""initial state has LoadingStatus.loading,
    has FormzSubmissionStatus.initial,
    contains a blank new player""", () {
      var sut = createSut(null);
      expect(sut.state, HasLoadingStatus(LoadingStatus.loading));
      expect(sut.state, HasFormStatus(FormzSubmissionStatus.initial));
      expect(sut.state.player.id, isEmpty);
    });

    blocTest<PlayerEditingCubit, PlayerEditingState>(
      """emits LoadingStatus.failed when a respository throws,
      a successfull retry emits LoadingStatus.loading
      then LoadingStatus.done""",
      setUp: arrangeOneRepositoryThrows,
      build: () => createSut(player),
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        arrangeRepositoriesReturn();
        cubit.loadPlayerData();
      },
      expect: () => [
        HasLoadingStatus(LoadingStatus.failed),
        HasLoadingStatus(LoadingStatus.loading),
        HasLoadingStatus(LoadingStatus.done),
      ],
    );

    blocTest<PlayerEditingCubit, PlayerEditingState>(
      """first emitted state has LoadingStatus.done,
      copies given player's attributes to state""",
      build: () => createSut(player),
      expect: () => [
        allOf(
          HasLoadingStatus(LoadingStatus.done),
          HasFirstNameInput(player.firstName),
          HasLastNameInput(player.lastName),
          HasDateOfBirthInput(DateFormat.yMd().format(player.dateOfBirth!)),
          HasNotesInput(player.notes),
          HasClubNameInput(player.club!.name),
          HasPlayingLevelInput(player.playingLevel),
        ),
      ],
    );

    blocTest<PlayerEditingCubit, PlayerEditingState>(
      """value inputs are emitted as new states""",
      build: () => createSut(null),
      skip: 1, // skip loading done state
      act: (cubit) async {
        cubit.firstNameChanged('changedFirstName');
        cubit.lastNameChanged('changedLastName');
        cubit.notesChanged('changedNotes');
        cubit.clubNameChanged('changedClubName');
        cubit.dateOfBirthChanged('2/2/2000');
        cubit.playingLevelChanged(playingLevel);
        cubit.registrationFormOpened();
        await Future.delayed(Duration.zero);
        cubit.registrationCancelled();
      },
      expect: () => [
        HasFirstNameInput('changedFirstName'),
        HasLastNameInput('changedLastName'),
        HasNotesInput('changedNotes'),
        HasClubNameInput('changedClubName'),
        HasDateOfBirthInput('2/2/2000'),
        HasDateOfBirthInput('2/2/2000'),
        HasPlayingLevelInput(playingLevel),
        HasPlayingLevelInput(playingLevel),
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
    void arrangeRepositoriesCreateAndUpdate() {
      when(
        () => playerRepository.create(any(), expand: any(named: 'expand')),
      ).thenAnswer(
        (invocation) async {
          var player = invocation.positionalArguments[0].copyWith(
            id: 'newPlayerID-aaa',
          );
          playerList.add(player);
          return player;
        },
      );
      when(
        () => playerRepository.update(any(), expand: any(named: 'expand')),
      ).thenAnswer(
        (invocation) async {
          var player = invocation.positionalArguments[0];
          playerList
            ..removeWhere((p) => p.id == player.id)
            ..add(player);
          return player;
        },
      );

      when(
        () => competitionRepository.update(any(), expand: any(named: 'expand')),
      ).thenAnswer(
        (invocation) async {
          var competition = invocation.positionalArguments[0];
          competitionList
            ..removeWhere((c) => c.id == competition.id)
            ..add(competition);
          return competition;
        },
      );

      when(
        () => clubRepository.create(any(), expand: any(named: 'expand')),
      ).thenAnswer(
        (invocation) async {
          var club = invocation.positionalArguments[0].copyWith(
            id: 'newClubID-aaaaaa',
          );
          clubList.add(club);
          return club;
        },
      );

      when(
        () => teamRepository.create(any(), expand: any(named: 'expand')),
      ).thenAnswer(
        (invocation) async {
          var team = invocation.positionalArguments[0].copyWith(
            id: 'newTeamID-aaaaa',
          );
          teamList.add(team);
          return team;
        },
      );
      when(
        () => teamRepository.update(any(), expand: any(named: 'expand')),
      ).thenAnswer(
        (invocation) async {
          var team = invocation.positionalArguments[0];
          teamList
            ..removeWhere((t) => t.id == team.id)
            ..add(team);
          return team;
        },
      );
      when(
        () => teamRepository.delete(any()),
      ).thenAnswer(
        (invocation) async {
          var team = invocation.positionalArguments[0];
          teamList.removeWhere((t) => t.id == team.id);
          var registeredCompetition = competitionList
              .where((c) => c.registrations.contains(team))
              .singleOrNull;
          if (registeredCompetition != null) {
            competitionList
              ..remove(registeredCompetition)
              ..add(registeredCompetition.copyWith(
                registrations:
                    List.of(registeredCompetition.registrations).toList()
                      ..remove(team),
              ));
          }
        },
      );
    }

    void arrangePlayerRepositoryThrows() {
      when(() => playerRepository.create(any(), expand: any(named: 'expand')))
          .thenAnswer((invocation) async =>
              throw CollectionQueryException('errorCode'));
    }

    void arrangeClubRepositoryThrows() {
      when(() => clubRepository.create(any(), expand: any(named: 'expand')))
          .thenAnswer((invocation) async =>
              throw CollectionQueryException('errorCode'));
    }

    void arrangeCompetitionRepositoryThrows() {
      when(() =>
              competitionRepository.update(any(), expand: any(named: 'expand')))
          .thenAnswer((invocation) async =>
              throw CollectionQueryException('errorCode'));
    }

    setUp(arrangeRepositoriesCreateAndUpdate);

    blocTest<PlayerEditingCubit, PlayerEditingState>(
      """submission of invalid form inputs creates
      FormzSubmissionStatus.failure,
      valid form inputs lead to FormzSubmissionStatus.inProgress,
      then FormzSubmissionStatus.success""",
      build: () => createSut(player),
      skip: 1, // skip loading done state
      act: (cubit) {
        // Leave name inputs empty to create invalid form submission
        cubit.formSubmitted();
        // Create valid form submission
        cubit.firstNameChanged('Alice');
        cubit.lastNameChanged('Smith');
        cubit.formSubmitted();
      },
      expect: () => [
        HasFormStatus(FormzSubmissionStatus.failure),
        HasFirstNameInput(isNotEmpty),
        HasLastNameInput(isNotEmpty),
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasFormStatus(FormzSubmissionStatus.success),
      ],
    );

    blocTest<PlayerEditingCubit, PlayerEditingState>(
      """FormzSubmissionStatus.inProgress then FormzSubmissionStatus.failure is
      emitted when Player repository throws during create""",
      setUp: arrangePlayerRepositoryThrows,
      build: () => createSut(null),
      skip: 1, // skip loading done state
      act: (cubit) {
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
      emitted when Club repository throws during create""",
      setUp: arrangeClubRepositoryThrows,
      build: () => createSut(null),
      skip: 1, // skip loading done state
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.firstNameChanged('Alice');
        cubit.lastNameChanged('Smith');
        cubit.clubNameChanged('Alice-Club');
        cubit.formSubmitted();
      },
      expect: () => [
        HasFirstNameInput(isNotEmpty),
        HasLastNameInput(isNotEmpty),
        HasClubNameInput(isNotEmpty),
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasFormStatus(FormzSubmissionStatus.failure),
      ],
    );

    blocTest<PlayerEditingCubit, PlayerEditingState>(
      """FormzSubmissionStatus.inProgress then FormzSubmissionStatus.failure is
      emitted when Competition repository throws during update""",
      setUp: arrangeCompetitionRepositoryThrows,
      build: () => createSut(null),
      skip: 1, // skip loading done state
      act: (cubit) async {
        await Future.delayed(Duration.zero);
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
        HasFormStatus(FormzSubmissionStatus.failure),
      ],
    );

    blocTest<PlayerEditingCubit, PlayerEditingState>(
      """value inputs are correctly applied to the Player object,
      a new Club is created with the given name""",
      build: () => createSut(null),
      skip: 9, // skip form input state changes
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.firstNameChanged('changedFirstName');
        cubit.lastNameChanged('changedLastName');
        cubit.notesChanged('changedEMail@example.com');
        cubit.clubNameChanged('changedClubName');
        cubit.dateOfBirthChanged('2/2/2000');
        cubit.playingLevelChanged(playingLevel);
        cubit.formSubmitted();
      },
      expect: () => [
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasPlayer(allOf(
          HasFirstName('changedFirstName'),
          HasLastName('changedLastName'),
          HasNotes('changedEMail@example.com'),
          HasClub(HasName('changedClubName')),
          HasDateOfBirth(DateFormat.yMd().parse('2/2/2000')),
          HasPlayingLevel(playingLevel),
        )),
      ],
      verify: (_) {
        expect(clubList, [HasName('changedClubName')]);
      },
    );

    blocTest<PlayerEditingCubit, PlayerEditingState>(
      """an existing Club is selected by name""",
      setUp: () => clubList = [Club.newClub(name: 'existing club')],
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
        HasPlayer(allOf(
          HasFirstName('changedFirstName'),
          HasLastName('changedLastName'),
          HasNotes(isEmpty),
          HasClub(HasName('existing club')),
          HasDateOfBirth(isNull),
          HasPlayingLevel(isNull),
        )),
      ],
      verify: (bloc) {
        expect(clubList, [HasName('existing club')]);
      },
    );

    blocTest<PlayerEditingCubit, PlayerEditingState>(
      """registering for a Competition correctly updates the Comptetition's
      registrations List,
      the Team that is used for the registration contains the edited player
      and the given team partner""",
      setUp: () => competitionList = [competition.copyWith()],
      build: () => createSut(player),
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.registrationFormOpened();
        cubit.registrationAdded(competition, player2);
        cubit.formSubmitted();
      },
      verify: (bloc) {
        expect(competitionList, hasLength(1));
        expect(competitionList.first.registrations, hasLength(1));
        expect(
          competitionList.first.registrations.first.players,
          allOf(contains(player), contains(player2)),
        );
        verify(
          () => competitionRepository.update(
            any(),
            expand: any(named: 'expand'),
          ),
        ).called(1);
      },
    );

    final teamWithPartner =
        Team.newTeam(players: [player, player2]).copyWith(id: 'teamId');
    blocTest<PlayerEditingCubit, PlayerEditingState>(
      """deregistering from a Competition correctly updates the Comptetition's
      registrations List,
      the Team the edited Player was part of has the Player removed""",
      setUp: () {
        teamList = [teamWithPartner];
        competitionList = [
          competition.copyWith(registrations: List.of(teamList)),
        ];
        playerList = List.of(teamWithPartner.players);
      },
      build: () => createSut(player),
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.registrationRemoved(cubit.state.registrations.value.first);
        cubit.formSubmitted();
      },
      verify: (bloc) {
        expect(competitionList, hasLength(1));
        expect(competitionList.first.registrations, hasLength(1));
        expect(teamList, hasLength(1));
        expect(
          teamList.first.players,
          allOf(contains(player2), isNot(contains(player))),
        );
        verify(
          () => competitionRepository.update(
            any(),
            expand: any(named: 'expand'),
          ),
        ).called(1);
      },
    );

    final soloTeam = Team.newTeam(players: [player]).copyWith(id: 'teamId');
    final soloTeam2 = Team.newTeam(players: [player2]).copyWith(id: 'teamId2');
    blocTest<PlayerEditingCubit, PlayerEditingState>(
      """deregistering from a Competition while in a Team solo deletes the team,
      registering with a partner that is already solo in a Team makes the
      partner join the new Team and deletes theirs""",
      setUp: () {
        teamList = [soloTeam, soloTeam2];
        competitionList = [
          competition.copyWith(registrations: [soloTeam, soloTeam2]),
        ];
        playerList = [player, player2];
      },
      build: () => createSut(player),
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.registrationRemoved(cubit.state.registrations.value.first);
        cubit.registrationFormOpened();
        cubit.registrationAdded(competitionList.first, player2);
        cubit.formSubmitted();
      },
      verify: (bloc) {
        expect(competitionList, hasLength(1));
        expect(competitionList.first.registrations, hasLength(1));
        expect(teamList, [HasId('newTeamID-aaaaa')]);
        expect(
          teamList.first.players,
          allOf(contains(player), contains(player2)),
        );
        verify(
          () => competitionRepository.update(
            any(),
            expand: any(named: 'expand'),
          ),
        ).called(2);
      },
    );

    final alreadyRegisteredTeam =
        Team.newTeam(players: [player]).copyWith(id: 'teamId');
    blocTest<PlayerEditingCubit, PlayerEditingState>(
      """trying to register twice for a Competition
      emits FormzSubmissionStatus.failure""",
      setUp: () {
        teamList = [alreadyRegisteredTeam];
        competitionList = [
          competition.copyWith(registrations: [alreadyRegisteredTeam]),
        ];
        playerList = List.of(alreadyRegisteredTeam.players);
      },
      build: () => createSut(player),
      skip: 3,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.registrationFormOpened();
        cubit.registrationAdded(competitionList.first, null);
        cubit.formSubmitted();
      },
      expect: () => [
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasFormStatus(FormzSubmissionStatus.failure),
      ],
      verify: (bloc) {
        expect(competitionList.first.registrations, [alreadyRegisteredTeam]);
      },
    );
  });
}
