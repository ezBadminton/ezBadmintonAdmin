import 'package:bloc_test/bloc_test.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_list_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCollectionRepository<M extends Model> extends Mock
    implements CollectionRepository<M> {}

class HasLoadingStatus extends CustomMatcher {
  HasLoadingStatus(matcher)
      : super(
          'State with LoadingStatus that is',
          'LoadingStatus',
          matcher,
        );
  @override
  featureValueOf(actual) => (actual as PlayerListState).loadingStatus;
}

void main() {
  late MockCollectionRepository<Player> playerRepository;
  late MockCollectionRepository<Competition> competitionRepository;
  late PlayerListCubit sut;

  // Create some players and competitions with teams for testing
  var players = List<Player>.unmodifiable(
    List.generate(16, (index) {
      return Player.newPlayer.copyWith(
        id: '$index',
      );
    }),
  );
  var mixedDoublesTeams = List<Team>.generate(
    3,
    (index) => Team(
        id: 'doubles$index',
        created: DateTime(2023),
        updated: DateTime(2023),
        players: players.sublist(2 * index, 2 * index + 2),
        resigned: false),
  );
  var singlesTeams = List<Team>.generate(
    6,
    (index) => Team(
        id: 'singels$index',
        created: DateTime(2023),
        updated: DateTime(2023),
        players: [players[index + mixedDoublesTeams.length]],
        resigned: false),
  );
  var mixedCompetition = Competition(
    id: 'doublesComp',
    created: DateTime(2023),
    updated: DateTime(2023),
    teamSize: 2,
    gender: GenderCategory.mixed,
    ageRestriction: AgeRestriction.none,
    minLevel: PlayingLevel.unrated,
    maxLevel: PlayingLevel.unrated,
    registrations: mixedDoublesTeams,
  );
  var singlesCompetition = Competition(
    id: 'singlesComp',
    created: DateTime(2023),
    updated: DateTime(2023),
    teamSize: 1,
    gender: GenderCategory.any,
    ageRestriction: AgeRestriction.none,
    minLevel: PlayingLevel.unrated,
    maxLevel: PlayingLevel.unrated,
    registrations: singlesTeams,
  );

  void arrangePlayerFetchThrows() {
    when(
      () => playerRepository.getList(expand: any(named: 'expand')),
    ).thenAnswer((_) async => throw CollectionFetchException('errorCode'));
  }

  void arrangeCompetitionFetchThrows() {
    when(
      () => competitionRepository.getList(expand: any(named: 'expand')),
    ).thenAnswer((_) async => throw CollectionFetchException('errorCode'));
  }

  setUp(() {
    playerRepository = MockCollectionRepository();
    competitionRepository = MockCollectionRepository();

    when(
      () => playerRepository.getList(expand: any(named: 'expand')),
    ).thenAnswer((invocation) async => players);

    when(
      () => competitionRepository.getList(expand: any(named: 'expand')),
    ).thenAnswer((invocation) async => [mixedCompetition, singlesCompetition]);

    sut = PlayerListCubit(
      playerRepository: playerRepository,
      competitionRepository: competitionRepository,
    );
  });

  group(
    'PlayerListCubit',
    () {
      test('initial state is loading', () {
        expect(
          PlayerListCubit(
            playerRepository: playerRepository,
            competitionRepository: competitionRepository,
          ).state,
          HasLoadingStatus(LoadingStatus.loading),
        );
      });

      blocTest<PlayerListCubit, PlayerListState>(
        """emits LoadingStatus.done when players and competitions have
        been fetched""",
        build: () => PlayerListCubit(
          playerRepository: playerRepository,
          competitionRepository: competitionRepository,
        ),
        expect: () => [
          // Players and competitions fetched
          HasLoadingStatus(LoadingStatus.done)
        ],
      );

      blocTest<PlayerListCubit, PlayerListState>(
        'emits LoadingStatus.failed when players cannot be fetched',
        setUp: () => arrangePlayerFetchThrows(),
        build: () => PlayerListCubit(
          playerRepository: playerRepository,
          competitionRepository: competitionRepository,
        ),
        expect: () => [
          // Player fetching failed
          HasLoadingStatus(LoadingStatus.failed),
        ],
      );

      blocTest<PlayerListCubit, PlayerListState>(
        'emits LoadingStatus.failed when competitions cannot be fetched',
        setUp: () => arrangeCompetitionFetchThrows(),
        build: () => PlayerListCubit(
          playerRepository: playerRepository,
          competitionRepository: competitionRepository,
        ),
        expect: () => [
          // Competition fetching failed
          HasLoadingStatus(LoadingStatus.failed),
        ],
      );

      blocTest<PlayerListCubit, PlayerListState>(
        """players and competitions are fetched and players are mapped to
        their registered competitions.""",
        build: () => sut,
        verify: (cubit) {
          expect(cubit.state.allPlayers, players);
          expect(cubit.state.filteredPlayers, players);
          expect(cubit.state.playerCompetitions.keys.toList(), players);
          for (var player in singlesTeams.expand((t) => t.players)) {
            expect(
              cubit.state.playerCompetitions[player],
              contains(singlesCompetition),
            );
          }
          for (var player in mixedDoublesTeams.expand((t) => t.players)) {
            expect(
              cubit.state.playerCompetitions[player],
              contains(mixedCompetition),
            );
          }
        },
      );

      blocTest<PlayerListCubit, PlayerListState>(
        "players are filtered by player attributes",
        build: () => sut,
        act: (cubit) => cubit.filterChanged({
          Player: (o) => int.parse((o as Player).id) < 5,
        }),
        verify: (cubit) {
          expect(cubit.state.filteredPlayers, players.sublist(0, 5));
        },
      );

      blocTest<PlayerListCubit, PlayerListState>(
        "players are filtered by competition attributes",
        build: () => sut,
        act: (cubit) => cubit.filterChanged({
          Competition: (o) =>
              (o as Competition).getCompetitionType() == CompetitionType.mixed,
        }),
        verify: (cubit) {
          expect(
            cubit.state.filteredPlayers,
            mixedDoublesTeams.expand((t) => t.players),
          );
        },
      );

      blocTest<PlayerListCubit, PlayerListState>(
        """players are filtered by player attributes
        combined with competition attributes""",
        build: () => sut,
        act: (cubit) => cubit.filterChanged({
          Competition: (o) =>
              (o as Competition).getCompetitionType() ==
              CompetitionType.singles,
          Player: (o) => int.parse((o as Player).id) < 5,
        }),
        verify: (cubit) {
          expect(
            cubit.state.filteredPlayers,
            singlesTeams.expand((t) => t.players).where(
                  (p) => players.sublist(0, 5).contains(p),
                ),
          );
        },
      );
    },
  );
}