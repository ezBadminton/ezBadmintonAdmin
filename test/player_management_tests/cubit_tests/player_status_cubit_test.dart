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

  PlayerStatusCubit createSut() {
    return PlayerStatusCubit(
      player: player,
      tournamentProgressGetter: () => TournamentProgressState(),
      playerRepository: playerRepository,
      matchDataRepository: matchDataRepository,
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
    matchDataRepository = TestCollectionRepository(
      throwing: throwing,
    );
  }

  void arrangePlayerRepositoryThrows() {
    playerRepository = TestCollectionRepository(throwing: true);
  }

  setUp(() {
    playerRepository = TestCollectionRepository();
    matchDataRepository = TestCollectionRepository();
    player = Player.newPlayer().copyWith(id: 'testplayer');

    arrangeRepositories(players: [player]);
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
    "emits FormzSubmissionStatus.success when repository updates",
    build: createSut,
    act: (cubit) async {
      await Future.delayed(const Duration(milliseconds: 2));
      cubit.statusChanged(PlayerStatus.forfeited);
    },
    expect: () => [
      HasFormStatus(FormzSubmissionStatus.inProgress),
      HasFormStatus(FormzSubmissionStatus.success),
      HasPlayer(HasStatus(PlayerStatus.forfeited)),
    ],
  );
}
