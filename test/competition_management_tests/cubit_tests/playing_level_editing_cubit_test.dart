import 'package:bloc_test/bloc_test.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/playing_level_editing/cubit/playing_level_editing_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';

import '../../common_matchers/model_matchers.dart';
import '../../common_matchers/state_matchers.dart';

class HasPlayingLevelName extends CustomMatcher {
  HasPlayingLevelName(matcher)
      : super(
          'State with playing level name',
          'String',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.playingLevelName.value;
}

class HasDisplayList extends CustomMatcher {
  HasDisplayList(matcher)
      : super(
          'State with display list',
          'list of PlayingLevel',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.displayPlayingLevels;
}

class HasRenamingPlayingLevel extends CustomMatcher {
  HasRenamingPlayingLevel(matcher)
      : super(
          'State with renaming playing level',
          'PlayingLevel',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.renamingPlayingLevel.value;
}

class HasPlayingLevelRename extends CustomMatcher {
  HasPlayingLevelRename(matcher)
      : super(
          'State with playing level rename',
          'String',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.playingLevelRename.value;
}

List<PlayingLevel> playingLevels = List.generate(
  3,
  (index) => PlayingLevel.newPlayingLevel(
    '$index',
    index,
  ).copyWith(id: '$index'),
);

List<Competition> competitions = [
  Competition.newCompetition(
    teamSize: 2,
    genderCategory: GenderCategory.mixed,
    playingLevel: playingLevels[1],
  ).copyWith(id: 'test-competition1'),
  Competition.newCompetition(
    teamSize: 2,
    genderCategory: GenderCategory.mixed,
    playingLevel: playingLevels[2],
  ).copyWith(id: 'test-competition2'),
];

List<Player> players = List.generate(
  5,
  (index) => Player.newPlayer().copyWith(id: 'player-$index'),
);

List<Team> teams = [
  Team.newTeam(
    players: [players[0], players[1]],
  ).copyWith(id: 'test-team-1'),
  Team.newTeam(
    players: [players[2], players[3]],
  ).copyWith(id: 'test-team-2'),
  Team.newTeam(
    players: [players[3], players[4]],
  ).copyWith(id: 'test-team-3'),
];

void main() {
  late CollectionRepository<PlayingLevel> playingLevelRepository;
  late CollectionRepository<Competition> competitionRepository;
  late CollectionRepository<Team> teamRepository;

  void arrangeRepositories({
    bool throwing = false,
    List<PlayingLevel> playingLevels = const [],
    List<Competition> competitions = const [],
    List<Team> teams = const [],
  }) {
    playingLevelRepository = TestCollectionRepository(
      initialCollection: playingLevels,
      throwing: throwing,
    );
    competitionRepository = TestCollectionRepository(
      initialCollection: competitions,
      throwing: throwing,
    );
    teamRepository = TestCollectionRepository(
      initialCollection: teams,
      throwing: throwing,
    );
  }

  void arrangeRegistrations(Competition competition, List<Team> teams) {
    competitionRepository.update(competition.copyWith(registrations: teams));
  }

  PlayingLevelEditingCubit createSut() {
    return PlayingLevelEditingCubit(
      playingLevelRepository: playingLevelRepository,
      competitionRepository: competitionRepository,
      teamRepository: teamRepository,
    );
  }

  setUp(() {
    arrangeRepositories();
  });

  group('PlayingLevelEditingCubit', () {
    test('initial state', () {
      PlayingLevelEditingCubit sut = createSut();
      expect(sut.state, HasLoadingStatus(LoadingStatus.loading));
      expect(sut.state, HasFormStatus(FormzSubmissionStatus.initial));
      expect(sut.state, HasRenamingPlayingLevel(isNull));
      expect(sut.state.formInteractable, isFalse);
      expect(sut.state.formSubmittable, isFalse);
    });

    blocTest<PlayingLevelEditingCubit, PlayingLevelEditingState>(
      'create playing levels',
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.playingLevelNameChanged('newPlayingLevel1');
        cubit.playingLevelSubmitted();
        await Future.delayed(Duration.zero);
        cubit.playingLevelNameChanged('newPlayingLevel2');
        cubit.playingLevelSubmitted();
      },
      skip: 1,
      expect: () => [
        HasPlayingLevelName('newPlayingLevel1'),
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasFormStatus(FormzSubmissionStatus.success),
        HasLoadingStatus(LoadingStatus.loading),
        HasLoadingStatus(LoadingStatus.done),
        HasPlayingLevelName('newPlayingLevel2'),
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasFormStatus(FormzSubmissionStatus.success),
        HasLoadingStatus(LoadingStatus.loading),
        HasLoadingStatus(LoadingStatus.done),
      ],
      verify: (_) async {
        List<PlayingLevel> collection = await playingLevelRepository.getList();
        expect(collection, hasLength(2));
        expect(
          collection,
          containsAll([
            allOf(
              HasName('newPlayingLevel1'),
              HasIndex(0),
            ),
            allOf(
              HasName('newPlayingLevel2'),
              HasIndex(1),
            ),
          ]),
        );
      },
    );

    blocTest<PlayingLevelEditingCubit, PlayingLevelEditingState>(
      'try to create duplicate name',
      setUp: () => arrangeRepositories(
        playingLevels: playingLevels,
      ),
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.playingLevelNameChanged(playingLevels[0].name);
        cubit.playingLevelSubmitted();
      },
      skip: 1,
      expect: () => [
        IsFormSubmittable(isFalse),
      ],
    );

    blocTest<PlayingLevelEditingCubit, PlayingLevelEditingState>(
      'delete playing level',
      setUp: () => arrangeRepositories(
        playingLevels: playingLevels,
      ),
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.playingLevelRemoved(playingLevels[0]);
      },
      skip: 1,
      expect: () => [
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasFormStatus(FormzSubmissionStatus.success),
        HasLoadingStatus(LoadingStatus.loading),
        allOf(
          HasLoadingStatus(LoadingStatus.done),
          HasDisplayList([HasIndex(0), HasIndex(1)]),
        ),
      ],
      verify: (cubit) async {
        List<PlayingLevel> collection = await playingLevelRepository.getList();
        expect(collection, hasLength(2));
        expect(
          collection,
          [
            // PlayingLevel indices are updated
            allOf(HasId(playingLevels[1].id), HasIndex(0)),
            allOf(HasId(playingLevels[2].id), HasIndex(1)),
          ],
        );
      },
    );

    blocTest<PlayingLevelEditingCubit, PlayingLevelEditingState>(
      'delete playing level with competition',
      setUp: () => arrangeRepositories(
        playingLevels: playingLevels,
        competitions: competitions,
      ),
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.playingLevelRemoved(playingLevels[1]);
        // Set dialog answer to true
        cubit.state.dialog.decisionCompleter!.complete(true);
      },
      skip: 1,
      expect: () => [
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasDialog(isA<CubitDialog<bool>>()),
        HasFormStatus(FormzSubmissionStatus.success),
        HasLoadingStatus(LoadingStatus.loading),
        allOf(
          HasLoadingStatus(LoadingStatus.done),
          HasDisplayList([HasIndex(0), HasIndex(1)]),
        ),
      ],
      verify: (cubit) async {
        List<PlayingLevel> playingLevelCollection =
            await playingLevelRepository.getList();
        List<Competition> competitionCollection =
            await competitionRepository.getList();
        expect(
          playingLevelCollection,
          [
            allOf(HasId(playingLevels[0].id), HasIndex(0)),
            allOf(HasId(playingLevels[2].id), HasIndex(1)),
          ],
        );
        expect(
          competitionCollection,
          everyElement(isNot(HasPlayingLevel(playingLevels[1]))),
        );
      },
    );

    blocTest<PlayingLevelEditingCubit, PlayingLevelEditingState>(
      'cancel deletion by dialog',
      setUp: () => arrangeRepositories(
        playingLevels: playingLevels,
        competitions: competitions,
      ),
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.playingLevelRemoved(playingLevels[1]);
        // Set dialog answer to false
        cubit.state.dialog.decisionCompleter!.complete(false);
      },
      skip: 1,
      expect: () => [
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasDialog(isA<CubitDialog<bool>>()),
        HasFormStatus(FormzSubmissionStatus.canceled),
      ],
    );

    blocTest<PlayingLevelEditingCubit, PlayingLevelEditingState>(
      'merge registrations of deleted competition',
      setUp: () {
        arrangeRepositories(
          playingLevels: playingLevels,
          competitions: competitions,
          teams: teams,
        );
        arrangeRegistrations(competitions[0], [teams[0], teams[1]]);
        arrangeRegistrations(competitions[1], [teams[2]]);
      },
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.playingLevelRemoved(playingLevels[1]);
        // Set dialog answer to merge with the playing level
        cubit.state.dialog.decisionCompleter!.complete(playingLevels[2]);
      },
      skip: 1,
      expect: () => [
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasDialog(isA<CubitDialog<PlayingLevel>>()),
        HasFormStatus(FormzSubmissionStatus.success),
        HasLoadingStatus(LoadingStatus.loading),
        HasLoadingStatus(LoadingStatus.done),
      ],
      verify: (_) async {
        List<Competition> competitionCollection =
            await competitionRepository.getList();
        List<List<Player>> previousTeamPlayers =
            teams.map((t) => t.players).toList();
        Set<Team> mergedTeams =
            competitionCollection.expand((c) => c.registrations).toSet();
        Set<Player> registeredPlayers =
            mergedTeams.expand((r) => r.players).toSet();
        expect(registeredPlayers, hasLength(5));
        for (Team mergedTeam in mergedTeams) {
          if (mergedTeam.players.length != 1) {
            // Check that team partners didn't change
            expect(
              previousTeamPlayers,
              contains(unorderedEquals(mergedTeam.players)),
            );
          }
        }
      },
    );

    blocTest<PlayingLevelEditingCubit, PlayingLevelEditingState>(
      'deny merge of registrations of deleted competition',
      setUp: () {
        arrangeRepositories(
          playingLevels: playingLevels,
          competitions: competitions,
          teams: teams,
        );
        arrangeRegistrations(competitions[0], [teams[0], teams[1]]);
        arrangeRegistrations(competitions[1], [teams[2]]);
      },
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.playingLevelRemoved(playingLevels[1]);
        // Set dialog answer to not merge and just delete
        cubit.state.dialog.decisionCompleter!.complete(
          PlayingLevel.newPlayingLevel('no-selection', -1),
        );
      },
      skip: 1,
      expect: () => [
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasDialog(isA<CubitDialog<PlayingLevel>>()),
        HasFormStatus(FormzSubmissionStatus.success),
        HasLoadingStatus(LoadingStatus.loading),
        HasLoadingStatus(LoadingStatus.done),
      ],
      verify: (_) async {
        List<Competition> competitionCollection =
            await competitionRepository.getList();
        Set<Team> allTeams =
            competitionCollection.expand((c) => c.registrations).toSet();
        Set<Player> registeredPlayers =
            allTeams.expand((r) => r.players).toSet();
        expect(allTeams, hasLength(1));
        expect(registeredPlayers, unorderedEquals([players[3], players[4]]));
      },
    );

    blocTest<PlayingLevelEditingCubit, PlayingLevelEditingState>(
      'cancel delete of competition with merge',
      setUp: () {
        arrangeRepositories(
          playingLevels: playingLevels,
          competitions: competitions,
          teams: teams,
        );
        arrangeRegistrations(competitions[0], [teams[0], teams[1]]);
        arrangeRegistrations(competitions[1], [teams[2]]);
      },
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.playingLevelRemoved(playingLevels[1]);
        // Set dialog answer cancel
        cubit.state.dialog.decisionCompleter!.complete(null);
      },
      skip: 1,
      expect: () => [
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasDialog(isA<CubitDialog<PlayingLevel>>()),
        HasFormStatus(FormzSubmissionStatus.canceled),
      ],
    );

    blocTest<PlayingLevelEditingCubit, PlayingLevelEditingState>(
      'rename playing level',
      setUp: () => arrangeRepositories(
        playingLevels: playingLevels,
      ),
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.playingLevelRenameFormOpened(playingLevels[0]);
        cubit.playingLevelRenameChanged('new-name');
        cubit.playingLevelRenameFormClosed();
      },
      skip: 1,
      expect: () => [
        HasRenamingPlayingLevel(playingLevels[0]),
        HasPlayingLevelRename('new-name'),
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasFormStatus(FormzSubmissionStatus.success),
        HasLoadingStatus(LoadingStatus.loading),
        HasLoadingStatus(LoadingStatus.done),
      ],
      verify: (_) async {
        List<PlayingLevel> collection = await playingLevelRepository.getList();
        expect(
          collection,
          contains(allOf(
            HasName('new-name'),
            HasId(playingLevels[0].id),
          )),
        );
      },
    );

    blocTest<PlayingLevelEditingCubit, PlayingLevelEditingState>(
      'try duplicate playing level rename',
      setUp: () => arrangeRepositories(
        playingLevels: playingLevels,
      ),
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.playingLevelRenameFormOpened(playingLevels[0]);
        cubit.playingLevelRenameChanged(playingLevels[1].name);
        cubit.playingLevelRenameFormClosed();
      },
      skip: 1,
      expect: () => [
        HasRenamingPlayingLevel(playingLevels[0]),
        HasPlayingLevelRename(playingLevels[1].name),
        allOf(
          HasRenamingPlayingLevel(isNull),
          HasPlayingLevelRename(''),
        ),
      ],
    );

    blocTest<PlayingLevelEditingCubit, PlayingLevelEditingState>(
      'reorder playing levels',
      setUp: () => arrangeRepositories(
        playingLevels: playingLevels,
      ),
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.playingLevelsReordered(0, 2);
        await Future.delayed(Duration.zero);
        cubit.playingLevelsReordered(1, 0);
      },
      skip: 1,
      expect: () => [
        allOf(
          HasFormStatus(FormzSubmissionStatus.inProgress),
          HasDisplayList([HasIndex(0), HasIndex(1), HasIndex(2)]),
        ),
        HasFormStatus(FormzSubmissionStatus.success),
        HasLoadingStatus(LoadingStatus.loading),
        HasLoadingStatus(LoadingStatus.done),
        allOf(
          HasFormStatus(FormzSubmissionStatus.inProgress),
          HasDisplayList([HasIndex(0), HasIndex(1), HasIndex(2)]),
        ),
        HasFormStatus(FormzSubmissionStatus.success),
        HasLoadingStatus(LoadingStatus.loading),
        HasLoadingStatus(LoadingStatus.done),
      ],
      verify: (_) async {
        List<PlayingLevel> collection = await playingLevelRepository.getList();
        expect(
          collection,
          unorderedEquals([
            allOf(HasId('2'), HasIndex(0)),
            allOf(HasId('1'), HasIndex(1)),
            allOf(HasId('0'), HasIndex(2)),
          ]),
        );
      },
    );
  });
}
