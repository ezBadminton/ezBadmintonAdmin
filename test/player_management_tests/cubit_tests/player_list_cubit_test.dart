import 'package:bloc_test/bloc_test.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_list_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../common_matchers/state_matchers.dart';

class MockCollectionRepository<M extends Model> extends Mock
    implements PocketbaseCollectionRepository<M> {}

class HasFilteredPlayers extends CustomMatcher {
  HasFilteredPlayers(matcher)
      : super(
          'State with filtered players list that is',
          'filtered players',
          matcher,
        );
  @override
  featureValueOf(actual) => (actual as PlayerListState).filteredPlayers;
}

void main() {
  late CollectionRepository<Player> playerRepository;
  late CollectionRepository<Competition> competitionRepository;
  late CollectionRepository<PlayingLevel> playingLevelRepository;
  late CollectionRepository<AgeGroup> ageGroupRepository;
  late CollectionRepository<Club> clubRepository;
  late PlayerListCubit sut;

  // Create some players and competitions with teams for testing
  var players = List<Player>.unmodifiable(
    List.generate(16, (index) {
      return Player.newPlayer().copyWith(
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
  var mixedCompetition = Competition.newCompetition(
    teamSize: 2,
    genderCategory: GenderCategory.mixed,
    registrations: mixedDoublesTeams,
  );
  var singlesCompetition = Competition.newCompetition(
    teamSize: 1,
    genderCategory: GenderCategory.any,
    registrations: singlesTeams,
  );

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

    playingLevelRepository = TestCollectionRepository();
    ageGroupRepository = TestCollectionRepository();
    clubRepository = TestCollectionRepository();
  }

  void arrangePlayerFetchThrows() {
    playerRepository = TestCollectionRepository(throwing: true);
  }

  void arrangeCompetitionFetchThrows() {
    competitionRepository = TestCollectionRepository(throwing: true);
  }

  PlayerListCubit createSut() {
    return PlayerListCubit(
      playerRepository: playerRepository,
      competitionRepository: competitionRepository,
      playingLevelRepository: playingLevelRepository,
      ageGroupRepository: ageGroupRepository,
      clubRepository: clubRepository,
    );
  }

  setUp(() {
    arrangeRepositories(
      players: players,
      competitions: [mixedCompetition, singlesCompetition],
    );

    sut = createSut();
  });

  group(
    'PlayerListCubit',
    () {
      test('initial state is loading', () {
        expect(
          createSut().state,
          HasLoadingStatus(LoadingStatus.loading),
        );
      });

      blocTest<PlayerListCubit, PlayerListState>(
        """emits LoadingStatus.done when collections have been fetched,
        emits a status with an updated filteredPlayers list""",
        build: createSut,
        expect: () => [
          // Players and competitions fetched
          HasLoadingStatus(LoadingStatus.done),
          HasFilteredPlayers(containsAll(players)),
        ],
      );

      blocTest<PlayerListCubit, PlayerListState>(
        'emits LoadingStatus.failed when players cannot be fetched',
        setUp: () => arrangePlayerFetchThrows(),
        build: createSut,
        expect: () => [
          // Player fetching failed
          HasLoadingStatus(LoadingStatus.failed),
        ],
      );

      blocTest<PlayerListCubit, PlayerListState>(
        'emits LoadingStatus.failed when competitions cannot be fetched',
        setUp: () => arrangeCompetitionFetchThrows(),
        build: createSut,
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
          expect(cubit.state.getCollection<Player>(), containsAll(players));
          expect(cubit.state.filteredPlayers, containsAll(players));
          expect(
            cubit.state.competitionRegistrations.keys.toList(),
            containsAll(players),
          );
          for (var player in singlesTeams.expand((t) => t.players)) {
            expect(
              cubit.state.competitionRegistrations[player]!
                  .map((r) => r.competition),
              contains(singlesCompetition),
            );
          }
          for (var player in mixedDoublesTeams.expand((t) => t.players)) {
            expect(
              cubit.state.competitionRegistrations[player]!
                  .map((r) => r.competition),
              contains(mixedCompetition),
            );
          }
        },
      );

      blocTest<PlayerListCubit, PlayerListState>(
        "players are filtered by player attributes",
        build: () => sut,
        act: (cubit) async {
          await Future.delayed(const Duration(milliseconds: 2));
          cubit.filterChanged({
            Player: (o) => int.parse((o as Player).id) < 5,
          });
        },
        verify: (cubit) {
          expect(
            cubit.state.filteredPlayers,
            containsAll(players.sublist(0, 5)),
          );
        },
      );

      blocTest<PlayerListCubit, PlayerListState>(
        "players are filtered by competition attributes",
        build: () => sut,
        act: (cubit) async {
          await Future.delayed(const Duration(milliseconds: 2));
          cubit.filterChanged({
            Competition: (o) =>
                (o as Competition).type == CompetitionType.mixed,
          });
        },
        verify: (cubit) {
          expect(
            cubit.state.filteredPlayers,
            containsAll(mixedDoublesTeams.expand((t) => t.players)),
          );
        },
      );

      blocTest<PlayerListCubit, PlayerListState>(
        """players are filtered by player attributes
        combined with competition attributes""",
        build: () => sut,
        act: (cubit) async {
          await Future.delayed(const Duration(milliseconds: 2));
          cubit.filterChanged({
            Competition: (o) =>
                (o as Competition).type == CompetitionType.singles,
            Player: (o) => int.parse((o as Player).id) < 5,
          });
        },
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
