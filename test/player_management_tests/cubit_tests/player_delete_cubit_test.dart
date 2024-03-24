import 'package:bloc_test/bloc_test.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_delete_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_delete_state.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';

import '../../common_matchers/state_matchers.dart';

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
  featureValueOf(actual) =>
      (actual as DialogState).dialog.decisionCompleter != null &&
      !actual.dialog.decisionCompleter!.isCompleted;
}

void main() {
  late CollectionRepository<Player> playerRepository;
  late Player player;

  PlayerDeleteCubit createSut() {
    return PlayerDeleteCubit(
      player: player,
      playerRepository: playerRepository,
    );
  }

  void arrangeRepositories({
    bool throwing = false,
    List<Player> players = const [],
  }) {
    playerRepository = TestCollectionRepository(
      throwing: throwing,
      initialCollection: players,
    );
  }

  setUp(() {
    playerRepository = TestCollectionRepository<Player>();

    player = Player.newPlayer().copyWith(id: 'test-player');

    arrangeRepositories();
  });

  group('PlayerDeleteCubit', () {
    test('initial state', () {
      PlayerDeleteCubit sut = createSut();
      expect(sut.state.formStatus, FormzSubmissionStatus.initial);
      expect(sut.state.player, player);
      expect(sut.state.dialog.decisionCompleter, isNull);
    });

    blocTest<PlayerDeleteCubit, PlayerDeleteState>(
      'confirm dialog',
      build: createSut,
      act: (cubit) {
        cubit.playerDeleted();
        expect(cubit.state, IsConfirmDialogShown(isTrue));
        cubit.state.dialog.decisionCompleter!.complete(false);
        expect(cubit.state, IsConfirmDialogShown(isFalse));
      },
      expect: () => [
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasFormStatus(FormzSubmissionStatus.canceled),
      ],
    );
  });
}
