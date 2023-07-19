import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_status_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_status_state.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../common_matchers/model_matchers.dart';
import '../../common_matchers/state_matchers.dart';

class MockCollectionRepository<M extends Model> extends Mock
    implements CollectionRepository<M> {}

void main() {
  late CollectionRepository<Player> playerRepository;
  late Player player;
  late PlayerStatusCubit sut;
  late StreamController<CollectionUpdateEvent<Player>>
      playerUpdateStreamController;

  PlayerStatusCubit createSut() {
    return PlayerStatusCubit(
      player: player,
      playerRepository: playerRepository,
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
    player = Player.newPlayer().copyWith(id: 'testplayer');
    playerUpdateStreamController = StreamController.broadcast();
    arrangePlayerRepositoryUpdates();
  });

  test('initial state is LoadingState.done', () {
    sut = createSut();
    expect(sut.state.loadingStatus, LoadingStatus.done);
  });

  blocTest<PlayerStatusCubit, PlayerStatusState>(
    'emits LoadingStatus.failed when repository throws',
    setUp: arrangePlayerRepositoryThrows,
    build: createSut,
    act: (cubit) => cubit.statusChanged(PlayerStatus.attending),
    expect: () => [
      HasLoadingStatus(LoadingStatus.loading),
      HasLoadingStatus(LoadingStatus.failed),
    ],
  );

  blocTest<PlayerStatusCubit, PlayerStatusState>(
    """emits LoadingStatus.done when repository updates,
    the update method has been called with a Player that has the changed
    PlayerStatus""",
    build: createSut,
    act: (cubit) => cubit.statusChanged(PlayerStatus.forfeited),
    expect: () => [
      HasLoadingStatus(LoadingStatus.loading),
      HasLoadingStatus(LoadingStatus.done),
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
