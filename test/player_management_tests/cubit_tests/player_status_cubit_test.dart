import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_status_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';

import '../../common_matchers/model_matchers.dart';
import '../../common_matchers/state_matchers.dart';

class MockCollectionRepository<M extends Model> extends Mock
    implements CollectionRepository<M> {}

void main() {
  late CollectionRepository<Player> playerRepository;
  late CollectionRepository<MatchData> matchDataRepository;
  late Player player;
  late PlayerStatusCubit sut;
  late StreamController<CollectionUpdateEvent<Player>>
      playerUpdateStreamController;

  PlayerStatusCubit createSut() {
    return PlayerStatusCubit(
      player: player,
      tournamentProgressGetter: () => TournamentProgressState(),
      playerRepository: playerRepository,
      matchDataRepository: matchDataRepository,
    );
  }

  void arrangePlayerRepositoryUpdates() {
    when(() => playerRepository.update(any(), expand: any(named: 'expand')))
        .thenAnswer((invocation) async => invocation.positionalArguments[0]);

    when(() => playerRepository.updateStream)
        .thenAnswer((_) => playerUpdateStreamController.stream);
  }

  void arrangePlayerRepositoryThrows() {
    when(() => playerRepository.update(any(), expand: any(named: 'expand')))
        .thenAnswer((_) async => throw CollectionQueryException('errorCode'));
  }

  setUpAll(() {
    registerFallbackValue(Player.newPlayer());
  });

  setUp(() {
    playerRepository = MockCollectionRepository();
    matchDataRepository = MockCollectionRepository();
    player = Player.newPlayer().copyWith(id: 'testplayer');
    playerUpdateStreamController = StreamController.broadcast();
    arrangePlayerRepositoryUpdates();
  });

  test('initial state is FormzSubmissionStatus.initial', () {
    sut = createSut();
    expect(sut.state.formStatus, FormzSubmissionStatus.initial);
  });

  blocTest<PlayerStatusCubit, PlayerStatusState>(
    'emits FormzSubmissionStatus.failure when repository throws',
    setUp: arrangePlayerRepositoryThrows,
    build: createSut,
    act: (cubit) => cubit.statusChanged(PlayerStatus.attending),
    expect: () => [
      HasFormStatus(FormzSubmissionStatus.inProgress),
      HasFormStatus(FormzSubmissionStatus.failure),
    ],
  );

  blocTest<PlayerStatusCubit, PlayerStatusState>(
    """emits FormzSubmissionStatus.success when repository updates,
    the update method has been called with a Player that has the changed
    PlayerStatus""",
    build: createSut,
    act: (cubit) => cubit.statusChanged(PlayerStatus.forfeited),
    expect: () => [
      HasFormStatus(FormzSubmissionStatus.inProgress),
      HasFormStatus(FormzSubmissionStatus.success),
    ],
    verify: (bloc) {
      verify(
        () => playerRepository.update(
            any(that: HasStatus(PlayerStatus.forfeited)),
            expand: any(named: 'expand')),
      ).called(1);
    },
  );

  blocTest<PlayerStatusCubit, PlayerStatusState>(
    "emits upated Player when update event happens for cubit's Player",
    build: createSut,
    act: (cubit) {
      // Update unrelated player to ensure cubit doesn't react
      playerUpdateStreamController.add(
        CollectionUpdateEvent.update(Player.newPlayer()),
      );
      // Update cubit's player
      playerUpdateStreamController.add(
        CollectionUpdateEvent.update(player.copyWith(firstName: 'updatedName')),
      );
    },
    expect: () => [
      HasPlayer(HasFirstName('updatedName')),
    ],
  );
}
