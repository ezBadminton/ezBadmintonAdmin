import 'package:bloc_test/bloc_test.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/models/competition_registration.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/partner_registration_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/partner_registration_state.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';

import '../../common_matchers/state_matchers.dart';

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

  PartnerRegistrationCubit createSut() {
    return PartnerRegistrationCubit(
      registration: registration,
      playerRepository: playerRepository,
      teamRepository: teamRepository,
      competitionRepository: competitionRepository,
    );
  }

  void arrangeRepositories({
    bool throwing = false,
    List<Player> players = const [],
    List<Competition> competitions = const [],
    List<Team> teams = const [],
  }) {
    playerRepository = TestCollectionRepository(
      throwing: throwing,
      initialCollection: players,
    );
    competitionRepository = TestCollectionRepository(
      throwing: throwing,
      initialCollection: competitions,
    );
    teamRepository = TestCollectionRepository(
      throwing: throwing,
      initialCollection: teams,
    );
  }

  setUp(() {
    playerRepository = TestCollectionRepository<Player>();
    teamRepository = TestCollectionRepository<Team>();
    competitionRepository = TestCollectionRepository<Competition>();

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

    arrangeRepositories(
      players: [player, partner],
      competitions: [competition],
      teams: [team],
    );
  });

  group('PartnerRegistrationCubit', () {
    test('initial state', () {
      PartnerRegistrationCubit sut = createSut();
      expect(sut.state.loadingStatus, LoadingStatus.loading);
      expect(sut.state.formStatus, FormzSubmissionStatus.initial);
      expect(sut.collectionUpdateSubscriptions, hasLength(6));
    });

    blocTest<PartnerRegistrationCubit, PartnerRegistrationState>(
      'initial load',
      build: createSut,
      wait: const Duration(milliseconds: 1),
      expect: () => [
        HasLoadingStatus(LoadingStatus.done),
      ],
      verify: (cubit) {
        expect(cubit.state.getCollection<Player>(), hasLength(2));
      },
    );

    blocTest<PartnerRegistrationCubit, PartnerRegistrationState>(
      'load failure',
      setUp: () => arrangeRepositories(throwing: true),
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

    test('player already has partner', () {
      team = Team.newTeam(players: [player, partner]).copyWith(id: 'test-team');
      registration = CompetitionRegistration(
        player: player,
        competition: competition,
        team: team,
      );

      arrangeRepositories(
        players: [player, partner],
        competitions: [competition],
        teams: [team],
      );

      expect(() => createSut(), throwsAssertionError);
    });

    blocTest<PartnerRegistrationCubit, PartnerRegistrationState>(
      'submit partner no existing team',
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.partnerChanged(partner);
        cubit.partnerSubmitted();
      },
      skip: 1,
      expect: () => [
        HasPartner(partner),
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasLoadingStatus(LoadingStatus.done),
        HasFormStatus(FormzSubmissionStatus.success),
      ],
    );
  });
}
