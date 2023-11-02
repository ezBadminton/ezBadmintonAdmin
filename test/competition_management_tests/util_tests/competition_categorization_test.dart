import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/models/competition_category.dart';
import 'package:ez_badminton_admin_app/competition_management/models/playing_category.dart';
import 'package:ez_badminton_admin_app/competition_management/utils/competition_categorization.dart'
    as sut;
import 'package:flutter_test/flutter_test.dart';

List<AgeGroup> ageGroups = [1, 2, 3]
    .map(
      (age) => AgeGroup.newAgeGroup(type: AgeGroupType.over, age: age)
          .copyWith(id: 'ageGroup$age'),
    )
    .toList();

List<PlayingLevel> playingLevels = [0, 1]
    .map(
      (level) => PlayingLevel.newPlayingLevel('$level', level)
          .copyWith(id: 'playingLevel$level'),
    )
    .toList();

List<Competition> competitions = [
  for (AgeGroup ageGroup in ageGroups)
    for (PlayingLevel playingLevel in playingLevels) ...[
      // 2 base disciplines per category
      Competition.newCompetition(
        teamSize: 1,
        genderCategory: GenderCategory.female,
        ageGroup: ageGroup,
        playingLevel: playingLevel,
      ),
      Competition.newCompetition(
        teamSize: 1,
        genderCategory: GenderCategory.male,
        ageGroup: ageGroup,
        playingLevel: playingLevel,
      ),
    ],
];

Tournament doubleCategorizedTournament = Tournament(
  id: 'double',
  created: DateTime.now(),
  updated: DateTime.now(),
  title: '',
  useAgeGroups: true,
  usePlayingLevels: true,
  dontReprintGameSheets: true,
  printQrCodes: true,
  playerRestTime: 20,
  queueMode: QueueMode.manual,
);

Tournament ageGroupCategorizedTournament = Tournament(
  id: 'ageGroups',
  created: DateTime.now(),
  updated: DateTime.now(),
  title: '',
  useAgeGroups: true,
  usePlayingLevels: false,
  dontReprintGameSheets: true,
  printQrCodes: true,
  playerRestTime: 20,
  queueMode: QueueMode.manual,
);

Tournament playingLevelCategorizedTournament = Tournament(
  id: 'playingLevels',
  created: DateTime.now(),
  updated: DateTime.now(),
  title: '',
  useAgeGroups: false,
  usePlayingLevels: true,
  dontReprintGameSheets: true,
  printQrCodes: true,
  playerRestTime: 20,
  queueMode: QueueMode.manual,
);

void main() {
  group('Competition categorization utils', () {
    test('possible playing categories', () {
      List<PlayingCategory> combinedCategories =
          sut.getPossiblePlayingCategories(
        doubleCategorizedTournament,
        ageGroups,
        playingLevels,
      );
      List<PlayingCategory> ageGroupCategories =
          sut.getPossiblePlayingCategories(
        ageGroupCategorizedTournament,
        ageGroups,
        playingLevels,
      );
      List<PlayingCategory> playingLevelCategories =
          sut.getPossiblePlayingCategories(
        playingLevelCategorizedTournament,
        [],
        playingLevels,
      );

      expect(
        combinedCategories,
        hasLength(ageGroups.length * playingLevels.length),
      );
      expect(combinedCategories[0].ageGroup, ageGroups[0]);
      expect(combinedCategories[0].playingLevel, playingLevels[0]);

      expect(ageGroupCategories.length, ageGroups.length);
      expect(ageGroupCategories[0].ageGroup, ageGroups[0]);
      expect(ageGroupCategories[0].playingLevel, isNull);

      expect(playingLevelCategories.length, playingLevels.length);
      expect(playingLevelCategories[0].ageGroup, isNull);
      expect(playingLevelCategories[0].playingLevel, playingLevels[0]);
    });

    test('competition grouping', () {
      List<List<Competition>> ageGroupCompetitions = sut.groupCompetitions(
        competitions,
        ignorePlayingLevels: true,
      );

      List<List<Competition>> playingLevelCompetitions = sut.groupCompetitions(
        competitions,
        ignoreAgeGroups: true,
      );

      // We have 2 base disciplines (men's/women's singles)
      // times the amount of age group
      expect(ageGroupCompetitions, hasLength(2 * ageGroups.length));
      for (List<Competition> ageGroup in ageGroupCompetitions) {
        expect(ageGroup, hasLength(playingLevels.length));
        expect(
          ageGroup,
          everyElement(predicate((competition) =>
              (competition as Competition).ageGroup ==
              ageGroup.first.ageGroup)),
        );
        expect(
          ageGroup,
          everyElement(predicate((competition) =>
              (competition as Competition).genderCategory ==
              ageGroup.first.genderCategory)),
        );
      }

      expect(playingLevelCompetitions, hasLength(2 * playingLevels.length));
      for (List<Competition> playingLevel in playingLevelCompetitions) {
        expect(playingLevel, hasLength(ageGroups.length));
        expect(
          playingLevel,
          everyElement(predicate((competition) =>
              (competition as Competition).playingLevel ==
              playingLevel.first.playingLevel)),
        );
        expect(
          playingLevel,
          everyElement(predicate((competition) =>
              (competition as Competition).genderCategory ==
              playingLevel.first.genderCategory)),
        );
      }
    });

    test('PlayingCategory mapping', () {
      List<PlayingCategory> possibleCategories =
          sut.getPossiblePlayingCategories(
        doubleCategorizedTournament,
        ageGroups,
        playingLevels,
      );
      Map<PlayingCategory, List<CompetitionDiscipline>> categoryMap =
          sut.mapPlayingCategories(
        possibleCategories,
        competitions,
      );

      expect(categoryMap, hasLength(possibleCategories.length));
      expect(categoryMap.values, everyElement(hasLength(2)));
      expect(
        categoryMap.values,
        everyElement(contains(CompetitionDiscipline.womensSingles)),
      );
      expect(
        categoryMap.values,
        everyElement(contains(CompetitionDiscipline.mensSingles)),
      );
    });

    test('Base discipline mapping', () {
      List<PlayingCategory> possibleCategories =
          sut.getPossiblePlayingCategories(
        doubleCategorizedTournament,
        ageGroups,
        playingLevels,
      );
      Map<CompetitionDiscipline, List<PlayingCategory>> disciplineMap =
          sut.mapDisciplines(competitions);

      expect(
        disciplineMap,
        hasLength(CompetitionDiscipline.baseCompetitions.length),
      );
      expect(
        disciplineMap[CompetitionDiscipline.womensSingles],
        possibleCategories,
      );
      expect(
        disciplineMap[CompetitionDiscipline.mensSingles],
        possibleCategories,
      );
      expect(disciplineMap[CompetitionDiscipline.mensDoubles], isEmpty);
    });
  });
}
