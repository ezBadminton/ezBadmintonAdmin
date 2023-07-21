// ignore_for_file: invalid_use_of_protected_member

import 'package:bloc_test/bloc_test.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_sorter/comparators/competition_comparator.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_list_cubit.dart';
import 'package:ez_badminton_admin_app/list_sorting/comparator/list_sorting_comparator.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common_matchers/state_matchers.dart';
import '../../test_collection_repository/test_collection_repository.dart';

class HasDisplayList extends CustomMatcher {
  HasDisplayList(matcher)
      : super(
          'State with display list of',
          'Competitions',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.displayCompetitionList;
}

List<Competition> competitions = [
  Competition.newCompetition(
    teamSize: 2,
    genderCategory: GenderCategory.male,
  ).copyWith(id: '1'),
  Competition.newCompetition(
    teamSize: 2,
    genderCategory: GenderCategory.female,
  ).copyWith(id: '2'),
];

void main() {
  late CollectionRepository<Competition> competitionRepository;
  late CollectionRepository<Tournament> tournamentRepository;
  late CollectionRepository<AgeGroup> ageGroupRepository;
  late CollectionRepository<PlayingLevel> playingLevelRepository;

  void arrangeRepositories({
    List<Competition> competitions = const [],
    List<Tournament> tournaments = const [],
    List<AgeGroup> ageGroups = const [],
    List<PlayingLevel> playingLevels = const [],
  }) {
    competitionRepository = TestCollectionRepository<Competition>(
      initialCollection: competitions,
    );
    tournamentRepository = TestCollectionRepository<Tournament>(
      initialCollection: tournaments,
    );
    ageGroupRepository = TestCollectionRepository<AgeGroup>(
      initialCollection: ageGroups,
    );
    playingLevelRepository = TestCollectionRepository<PlayingLevel>(
      initialCollection: playingLevels,
    );
  }

  CompetitionListCubit createSut() {
    return CompetitionListCubit(
      competitionRepository: competitionRepository,
      tournamentRepository: tournamentRepository,
      ageGroupRepository: ageGroupRepository,
      playingLevelRepository: playingLevelRepository,
    );
  }

  setUp(() {
    arrangeRepositories();
  });

  group('CompetitionListCubit', () {
    test('initial state', () async {
      CompetitionListCubit sut = createSut();
      expect(sut.state, HasLoadingStatus(LoadingStatus.loading));
      expect(sut.state.displayCompetitionList, isEmpty);
      await Future.delayed(Duration.zero);
      expect(competitionRepository.updateStreamController.hasListener, isTrue);
      expect(tournamentRepository.updateStreamController.hasListener, isTrue);
      expect(ageGroupRepository.updateStreamController.hasListener, isTrue);
      expect(playingLevelRepository.updateStreamController.hasListener, isTrue);
    });

    blocTest<CompetitionListCubit, CompetitionListState>(
      'display list',
      setUp: () => arrangeRepositories(competitions: competitions),
      build: createSut,
      act: (cubit) async {
        // Wait for collection loading
        await Future.delayed(Duration.zero);
      },
      expect: () => [
        allOf(
          HasLoadingStatus(LoadingStatus.done),
          HasDisplayList(containsAll(competitions)),
        ),
      ],
    );

    CompetitionComparator comparator = const CompetitionComparator();
    CompetitionComparator reverseComparator =
        comparator.copyWith(ComparatorMode.descending);
    blocTest<CompetitionListCubit, CompetitionListState>(
      'sorting comparator',
      setUp: () => arrangeRepositories(competitions: competitions),
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.comparatorChanged(comparator);
        await Future.delayed(Duration.zero);
        cubit.comparatorChanged(reverseComparator);
      },
      skip: 1,
      expect: () => [
        HasComparator(comparator),
        HasDisplayList(containsAllInOrder([competitions[1], competitions[0]])),
        HasComparator(reverseComparator),
        HasDisplayList(containsAllInOrder([competitions[0], competitions[1]])),
      ],
    );
  });
}
