// ignore_for_file: invalid_use_of_protected_member

import 'package:bloc_test/bloc_test.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_categorization_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_categorization_state.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';

import '../../common_matchers/model_matchers.dart';
import '../../common_matchers/state_matchers.dart';

class MockAppLocalizations extends Mock implements AppLocalizations {}

void main() {
  late AppLocalizations l10n;
  late CollectionRepository<Tournament> tournamentRepository;
  late CollectionRepository<Competition> competitionRepository;
  late CollectionRepository<AgeGroup> ageGroupRepository;
  late CollectionRepository<PlayingLevel> playingLevelRepository;

  CompetitionCategorizationCubit createSut() {
    return CompetitionCategorizationCubit(
      l10n: l10n,
      tournamentRepository: tournamentRepository,
      competitionRepository: competitionRepository,
      ageGroupRepository: ageGroupRepository,
      playingLevelRepository: playingLevelRepository,
    );
  }

  void arrangeRepositories({
    bool throwing = false,
    Duration loadTime = const Duration(milliseconds: 20),
    bool useAgeGroups = true,
    bool usePlayingLevels = true,
  }) {
    Tournament tournament = Tournament(
      id: 'tournament',
      created: DateTime.now(),
      updated: DateTime.now(),
      title: 'test!',
      useAgeGroups: useAgeGroups,
      usePlayingLevels: usePlayingLevels,
      dontReprintGameSheets: true,
      printQrCodes: true,
      playerRestTime: 20,
      queueMode: QueueMode.manual,
    );

    tournamentRepository = TestCollectionRepository<Tournament>(
      initialCollection: [tournament],
      throwing: throwing,
      loadTime: loadTime,
    );
    competitionRepository = TestCollectionRepository<Competition>(
      throwing: throwing,
      loadTime: loadTime,
    );
    ageGroupRepository = TestCollectionRepository<AgeGroup>(
      throwing: throwing,
      loadTime: loadTime,
    );
    playingLevelRepository = TestCollectionRepository<PlayingLevel>(
      throwing: throwing,
      loadTime: loadTime,
    );
  }

  setUp(() {
    l10n = MockAppLocalizations();

    arrangeRepositories();
  });

  group('CompetitionCategorizationCubit', () {
    test('intial state', () async {
      CompetitionCategorizationCubit sut = createSut();
      expect(sut.state, HasLoadingStatus(LoadingStatus.loading));
      expect(sut.state, HasFormStatus(FormzSubmissionStatus.initial));
      await Future.delayed(Duration.zero);
      expect(competitionRepository.updateStreamController.hasListener, isTrue);
      expect(ageGroupRepository.updateStreamController.hasListener, isTrue);
      expect(playingLevelRepository.updateStreamController.hasListener, isTrue);
    });

    blocTest<CompetitionCategorizationCubit, CompetitionCategorizationState>(
      'loading status when repository throws',
      setUp: () => arrangeRepositories(
        throwing: true,
        useAgeGroups: false,
        usePlayingLevels: false,
      ),
      build: createSut,
      wait: const Duration(milliseconds: 25),
      expect: () => [HasLoadingStatus(LoadingStatus.failed)],
    );

    blocTest<CompetitionCategorizationCubit, CompetitionCategorizationState>(
      'loading status',
      setUp: () => arrangeRepositories(
        useAgeGroups: false,
        usePlayingLevels: false,
      ),
      wait: const Duration(milliseconds: 25),
      build: createSut,
      expect: () => [
        HasLoadingStatus(LoadingStatus.done),
      ],
    );

    blocTest<CompetitionCategorizationCubit, CompetitionCategorizationState>(
      'set categorization of Tournament',
      setUp: () => arrangeRepositories(
        useAgeGroups: false,
        usePlayingLevels: false,
      ),
      build: createSut,
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 40));
        cubit.useAgeGroupsChanged(true);
        await Future.delayed(Duration.zero);
        cubit.usePlayingLevelsChanged(true);
      },
      skip: 1,
      expect: () => [
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasFormStatus(FormzSubmissionStatus.success),
        allOf(
          HasCollection<Tournament>(
            hasLength(1),
          ),
          HasCollection<Tournament>(
            contains(HasAgeGroupCategorization(isTrue)),
          ),
        ),
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasFormStatus(FormzSubmissionStatus.success),
        allOf(
          HasCollection<Tournament>(
            hasLength(1),
          ),
          HasCollection<Tournament>(
            contains(HasPlayingLevelCategorization(isTrue)),
          ),
        ),
      ],
    );
  });
}
