import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/models/competition_registration.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/partner_registration_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/partner_registration_state.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';

import '../../common_matchers/model_matchers.dart';
import '../../common_matchers/state_matchers.dart';

class MockCollectionRepository<M extends Model> extends Mock
    implements CollectionRepository<M> {}

class HasInputVisibility extends CustomMatcher {
  HasInputVisibility(matcher)
      : super(
          'State input visibility',
          'input visibility bool',
          matcher,
        );
  @override
  featureValueOf(actual) =>
      (actual as PartnerRegistrationState).showPartnerInput;
}

class HasPartner extends CustomMatcher {
  HasPartner(matcher)
      : super(
          'State with partner',
          'partner Player',
          matcher,
        );
  @override
  featureValueOf(actual) => (actual as PartnerRegistrationState).partner.value;
}

void main() {
  late CollectionRepository<Player> playerRepository;
  late CollectionRepository<Team> teamRepository;
  late CollectionRepository<Competition> competitionRepository;
  late CompetitionRegistration registration;
  late Player player;
  late Player partner;
  late Competition competition;
  late Team team;
  late StreamController<CollectionUpdateEvent<Team>> teamUpdateController;
  late StreamController<CollectionUpdateEvent<Player>> playerUpdateController;
  late StreamController<CollectionUpdateEvent<Competition>>
      competitionUpdateController;

  PartnerRegistrationCubit createSut() {
    return PartnerRegistrationCubit(
      registration: registration,
      playerRepository: playerRepository,
      teamRepository: teamRepository,
      competitionRepository: competitionRepository,
    );
  }

  void arrangeRepositoriesReturn() {
    when(() => playerRepository.getList(expand: any(named: 'expand')))
        .thenAnswer((invocation) async => []);
  }

  void arrangeRepositoryUpdateStreams() {
    teamUpdateController = StreamController.broadcast();
    when(() => teamRepository.updateStream)
        .thenAnswer((invocation) => teamUpdateController.stream);

    playerUpdateController = StreamController.broadcast();
    when(() => playerRepository.updateStream)
        .thenAnswer((invocation) => playerUpdateController.stream);

    competitionUpdateController = StreamController.broadcast();
    when(() => competitionRepository.updateStream)
        .thenAnswer((invocation) => competitionUpdateController.stream);
  }

  void arrangePlayerRepositoryThrows() {
    when(
      () => playerRepository.getList(expand: any(named: 'expand')),
    ).thenAnswer(
      (invocation) async => throw CollectionQueryException('errorCode'),
    );
  }

  void arrangeRepositoriesUpdateAndDelete() {
    when(
      () => competitionRepository.update(any(), expand: any(named: 'expand')),
    ).thenAnswer(
      (invocation) async => invocation.positionalArguments[0],
    );

    when(
      () => teamRepository.update(any(), expand: any(named: 'expand')),
    ).thenAnswer(
      (invocation) async => invocation.positionalArguments[0],
    );
    when(
      () => teamRepository.delete(any()),
    ).thenAnswer(
      (invocation) async => true,
    );
  }

  void arrangeTeamRepositoryDeleteThrows() {
    when(
      () => teamRepository.delete(any()),
    ).thenAnswer(
      (invocation) async => throw CollectionQueryException('errorCode'),
    );
  }

  void arrangeTeamRepositoryUpdateThrows() {
    when(
      () => teamRepository.update(any(), expand: any(named: 'expand')),
    ).thenAnswer(
      (invocation) async => throw CollectionQueryException('errorCode'),
    );
  }

  void arrangePartnerHasExistingTeam() {
    Team partnerTeam =
        Team.newTeam(players: [partner]).copyWith(id: 'test-parter-team');
    competition = competition.copyWith(registrations: [partnerTeam]);
    registration = CompetitionRegistration(
      player: player,
      competition: competition,
      team: team,
    );
  }

  void arrangePlayerAlreadyHasPartner() {
    Team partnerTeam = Team.newTeam(players: [player, partner])
        .copyWith(id: 'already-partnered-team');
    competition = competition.copyWith(registrations: [partnerTeam]);
    registration = CompetitionRegistration(
      player: player,
      competition: competition,
      team: partnerTeam,
    );
  }

  setUpAll(() {
    registerFallbackValue(Competition.newCompetition(
      teamSize: 1,
      genderCategory: GenderCategory.any,
    ));
    registerFallbackValue(Team.newTeam());
    registerFallbackValue(Player.newPlayer());
  });

  setUp(() {
    playerRepository = MockCollectionRepository<Player>();
    teamRepository = MockCollectionRepository<Team>();
    competitionRepository = MockCollectionRepository<Competition>();

    player = Player.newPlayer().copyWith(id: 'test-player');
    partner = Player.newPlayer().copyWith(id: 'test-partner');
    competition = Competition.newCompetition(
      teamSize: 2,
      genderCategory: GenderCategory.mixed,
    ).copyWith(id: 'test-competition');
    team = Team.newTeam(players: [player]).copyWith(id: 'test-team');
    registration = CompetitionRegistration(
      player: player,
      competition: competition,
      team: team,
    );

    arrangeRepositoriesReturn();
    arrangeRepositoryUpdateStreams();
  });

  group('PartnerRegistrationCubit', () {
    test('initial state', () {
      PartnerRegistrationCubit sut = createSut();
      expect(sut.state.loadingStatus, LoadingStatus.loading);
      expect(sut.state.formStatus, FormzSubmissionStatus.initial);
      expect(teamUpdateController.hasListener, isTrue);
    });

    blocTest<PartnerRegistrationCubit, PartnerRegistrationState>(
      'update-stream subscription cancel',
      build: createSut,
      verify: (_) {
        expect(teamUpdateController.hasListener, isFalse);
      },
    );

    blocTest<PartnerRegistrationCubit, PartnerRegistrationState>(
      'initial load',
      build: createSut,
      expect: () => [
        HasLoadingStatus(LoadingStatus.done),
      ],
      verify: (cubit) {
        expect(cubit.state.getCollection<Player>(), []);
      },
    );

    blocTest<PartnerRegistrationCubit, PartnerRegistrationState>(
      'reload',
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.loadPlayerData();
      },
      expect: () => [
        HasLoadingStatus(LoadingStatus.done),
        HasLoadingStatus(LoadingStatus.loading),
        HasLoadingStatus(LoadingStatus.done),
      ],
    );

    blocTest<PartnerRegistrationCubit, PartnerRegistrationState>(
      'load failure',
      setUp: arrangePlayerRepositoryThrows,
      build: createSut,
      expect: () => [
        HasLoadingStatus(LoadingStatus.failed),
      ],
    );

    blocTest<PartnerRegistrationCubit, PartnerRegistrationState>(
      'input visibility toggle',
      build: createSut,
      skip: 1,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.partnerInputVisibilityChanged(true);
        cubit.partnerInputVisibilityChanged(false);
      },
      expect: () => [
        HasInputVisibility(isTrue),
        HasInputVisibility(isFalse),
      ],
    );

    blocTest<PartnerRegistrationCubit, PartnerRegistrationState>(
      'partner change',
      build: createSut,
      skip: 1,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.partnerChanged(partner);
        cubit.partnerChanged(null);
      },
      expect: () => [
        HasPartner(partner),
        HasPartner(isNull),
      ],
    );

    blocTest<PartnerRegistrationCubit, PartnerRegistrationState>(
      'team collection update event',
      build: createSut,
      skip: 1,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.partnerChanged(partner);
        teamUpdateController.add(
          CollectionUpdateEvent.update(Team.newTeam(players: [partner])),
        );
        await Future.delayed(Duration.zero);
        cubit.partnerChanged(partner);
        teamUpdateController.add(
          CollectionUpdateEvent.update(Team.newTeam(players: [player])),
        );
      },
      expect: () => [
        HasPartner(partner),
        HasPartner(isNull),
        HasPartner(partner),
      ],
    );

    blocTest<PartnerRegistrationCubit, PartnerRegistrationState>(
      'player collection update event',
      build: createSut,
      skip: 1,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        playerUpdateController.add(
          CollectionUpdateEvent.update(Player.newPlayer()),
        );
        await Future.delayed(Duration.zero);
        playerUpdateController.add(
          CollectionUpdateEvent.create(Player.newPlayer()),
        );
        await Future.delayed(Duration.zero);
        playerUpdateController.add(
          CollectionUpdateEvent.delete(Player.newPlayer()),
        );
      },
      expect: () => [
        HasLoadingStatus(LoadingStatus.loading),
        HasLoadingStatus(LoadingStatus.done),
        HasLoadingStatus(LoadingStatus.loading),
        HasLoadingStatus(LoadingStatus.done),
      ],
    );

    test('player already has partner', () {
      arrangePlayerAlreadyHasPartner();
      expect(() => createSut(), throwsAssertionError);
    });

    blocTest<PartnerRegistrationCubit, PartnerRegistrationState>(
      'submit partner no existing team',
      setUp: arrangeRepositoriesUpdateAndDelete,
      build: createSut,
      skip: 1,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.partnerChanged(partner);
        cubit.partnerSubmitted();
      },
      expect: () => [
        HasPartner(partner),
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasFormStatus(FormzSubmissionStatus.success),
      ],
      verify: (_) {
        verify(
          () => teamRepository.update(
            any(that: HasPlayers(containsAll([player, partner]))),
            expand: any(named: 'expand'),
          ),
        ).called(1);
        verifyNever(() => teamRepository.delete(any()));
      },
    );

    blocTest<PartnerRegistrationCubit, PartnerRegistrationState>(
      'submit partner with existing team',
      setUp: () {
        arrangeRepositoriesUpdateAndDelete();
        arrangePartnerHasExistingTeam();
      },
      build: createSut,
      skip: 1,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.partnerChanged(partner);
        cubit.partnerSubmitted();
      },
      expect: () => [
        HasPartner(partner),
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasFormStatus(FormzSubmissionStatus.success),
      ],
      verify: (_) {
        verify(
          () => teamRepository.update(
            any(that: HasPlayers(containsAll([player, partner]))),
            expand: any(named: 'expand'),
          ),
        ).called(1);
        verify(
          () => teamRepository.delete(any(that: HasPlayers([partner]))),
        ).called(1);
      },
    );

    blocTest<PartnerRegistrationCubit, PartnerRegistrationState>(
      'submit partner failure states',
      setUp: () {
        arrangeRepositoriesUpdateAndDelete();
        arrangePartnerHasExistingTeam();
      },
      build: createSut,
      skip: 1,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.partnerChanged(partner);

        arrangeTeamRepositoryDeleteThrows();
        cubit.partnerSubmitted();
        await Future.delayed(Duration.zero);

        arrangeRepositoriesUpdateAndDelete();
        arrangeTeamRepositoryUpdateThrows();
        cubit.partnerSubmitted();
        await Future.delayed(Duration.zero);
      },
      expect: () => [
        HasPartner(partner),
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasFormStatus(FormzSubmissionStatus.failure),
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasFormStatus(FormzSubmissionStatus.failure),
      ],
    );
  });
}
