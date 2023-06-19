import 'package:bloc_test/bloc_test.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_delete_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_delete_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';

import '../common_matchers/model_matchers.dart';
import '../common_matchers/state_matchers.dart';

class MockCollectionRepository<M extends Model> extends Mock
    implements CollectionRepository<M> {}

class IsConfirmDialogShown extends CustomMatcher {
  IsConfirmDialogShown(matcher)
      : super(
          'Confirm dialog visibility is',
          'bool',
          matcher,
        );

  @override
  featureValueOf(actual) => (actual as PlayerDeleteState).showConfirmDialog;
}

void main() {
  late CollectionRepository<Player> playerRepository;
  late CollectionRepository<Competition> competitionRepository;
  late CollectionRepository<Team> teamRepository;

  late Player player;
  late List<Competition> competitions;

  PlayerDeleteCubit createSut() {
    return PlayerDeleteCubit(
      player: player,
      playerRepository: playerRepository,
      competitionRepository: competitionRepository,
      teamRepository: teamRepository,
    );
  }

  void arrangeCompetitionRepositoryReturns() {
    when(
      () => competitionRepository.getList(expand: any(named: 'expand')),
    ).thenAnswer(
      (invocation) async => competitions,
    );
  }

  void arrangeRepositoriesUpdate() {
    when(
      () => competitionRepository.update(any(), expand: any(named: 'expand')),
    ).thenAnswer(
      (invocation) async => invocation.positionalArguments[0] as Competition,
    );

    when(
      () => teamRepository.update(any(), expand: any(named: 'expand')),
    ).thenAnswer(
      (invocation) async => invocation.positionalArguments[0] as Team,
    );

    when(
      () => playerRepository.delete(any()),
    ).thenAnswer(
      (invocation) async => true,
    );

    when(
      () => teamRepository.delete(any()),
    ).thenAnswer(
      (invocation) async => true,
    );
  }

  void arrangePlayerHas2Registrations() {
    Team singlesTeam =
        Team.newTeam(players: [player]).copyWith(id: 'singles-team');
    Competition singlesCompetition = Competition.newCompetition(
      teamSize: 1,
      genderCategory: GenderCategory.any,
    ).copyWith(
      id: 'singles-competition',
      registrations: [
        singlesTeam,
      ],
    );

    Player partner = Player.newPlayer().copyWith(id: 'partner-player');
    Team doublesTeam =
        Team.newTeam(players: [player, partner]).copyWith(id: 'doubles-team');
    Competition doublesCompetition = Competition.newCompetition(
      teamSize: 2,
      genderCategory: GenderCategory.any,
    ).copyWith(
      id: 'doubles-competition',
      registrations: [
        doublesTeam,
      ],
    );

    competitions = [singlesCompetition, doublesCompetition];
  }

  void arrangeCompetitionRepositoryGetThrows() {
    when(
      () => competitionRepository.getList(expand: any(named: 'expand')),
    ).thenAnswer(
      (invocation) async => throw CollectionQueryException('errorCode'),
    );
  }

  void arrangeCompetitionRepositoryUpdateThrows() {
    when(
      () => competitionRepository.update(any(), expand: any(named: 'expand')),
    ).thenAnswer(
      (invocation) async => throw CollectionQueryException('errorCode'),
    );
  }

  void arrangePlayerRepositoryDeleteThrows() {
    when(
      () => playerRepository.delete(any()),
    ).thenAnswer(
      (invocation) async => throw CollectionQueryException('errorCode'),
    );
  }

  setUpAll(() {
    registerFallbackValue(Player.newPlayer());
    registerFallbackValue(Competition.newCompetition(
      teamSize: 1,
      genderCategory: GenderCategory.any,
    ));
    registerFallbackValue(Team.newTeam());
  });

  setUp(() {
    playerRepository = MockCollectionRepository<Player>();
    competitionRepository = MockCollectionRepository<Competition>();
    teamRepository = MockCollectionRepository<Team>();

    player = Player.newPlayer().copyWith(id: 'test-player');
    competitions = [];

    arrangeCompetitionRepositoryReturns();
    arrangeRepositoriesUpdate();
  });

  group('PlayerDeleteCubit', () {
    test('initial state', () {
      PlayerDeleteCubit sut = createSut();
      expect(sut.state.formStatus, FormzSubmissionStatus.initial);
      expect(sut.state.player, player);
      expect(sut.state.showConfirmDialog, isFalse);
    });

    blocTest<PlayerDeleteCubit, PlayerDeleteState>(
      'confirm dialog',
      build: createSut,
      act: (cubit) {
        cubit.confirmDialogOpened();
        cubit.confirmChoiceMade(false);
      },
      expect: () => [
        IsConfirmDialogShown(isTrue),
        allOf(
          IsConfirmDialogShown(isFalse),
          HasFormStatus(FormzSubmissionStatus.initial),
        ),
      ],
    );

    blocTest<PlayerDeleteCubit, PlayerDeleteState>(
      'delete Player, with registrations',
      setUp: arrangePlayerHas2Registrations,
      build: createSut,
      act: (cubit) {
        cubit.confirmChoiceMade(true);
      },
      expect: () => [
        IsConfirmDialogShown(isFalse),
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasFormStatus(FormzSubmissionStatus.success),
      ],
      verify: (_) {
        verify(
          () => competitionRepository.getList(expand: any(named: 'expand')),
        ).called(1);
        verify(
          () => competitionRepository.update(
            any(),
            expand: any(named: 'expand'),
          ),
        ).called(2);
        verify(
          () => teamRepository.delete(any(that: HasId('singles-team'))),
        ).called(1);
        verify(
          () => teamRepository.update(
            any(that: HasPlayers([isNot(player)])),
            expand: any(named: 'expand'),
          ),
        ).called(1);
        verify(
          () => playerRepository.delete(any(that: equals(player))),
        ).called(1);
      },
    );

    blocTest<PlayerDeleteCubit, PlayerDeleteState>(
      'delete Player, repository throws',
      setUp: arrangePlayerHas2Registrations,
      build: createSut,
      act: (cubit) async {
        arrangeCompetitionRepositoryGetThrows();
        cubit.confirmChoiceMade(true);
        await Future.delayed(Duration.zero);
        expect(cubit.state.formStatus, FormzSubmissionStatus.failure);

        arrangeCompetitionRepositoryReturns();
        arrangeCompetitionRepositoryUpdateThrows();
        cubit.confirmChoiceMade(true);
        await Future.delayed(Duration.zero);
        expect(cubit.state.formStatus, FormzSubmissionStatus.failure);

        arrangeRepositoriesUpdate();
        arrangePlayerRepositoryDeleteThrows();
        cubit.confirmChoiceMade(true);
        await Future.delayed(Duration.zero);
        expect(cubit.state.formStatus, FormzSubmissionStatus.failure);
      },
    );
  });
}
