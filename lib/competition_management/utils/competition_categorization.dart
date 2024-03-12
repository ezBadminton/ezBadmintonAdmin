import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/models/competition_category.dart';
import 'package:ez_badminton_admin_app/competition_management/models/playing_category.dart';

/// Creates a list of all possible [PlayingCategory]s.
///
/// The list contains a [PlayingCategory] for each combination
/// of [AgeGroup] and [PlayingLevel] that comes
/// from the [ageGroups] and [playingLevels] lists.
///
/// Example:
///
/// With `ageGroups = [O19, U19]` and `playingLevels = [beginner, pro]`
/// the possible playing categories would be
/// * `O19 beginner`
/// * `O19 pro`
/// * `U19 beginner`
/// * `U19 pro`
List<PlayingCategory> getPossiblePlayingCategories(
  Tournament tournament,
  List<AgeGroup> ageGroups,
  List<PlayingLevel> playingLevels,
) {
  List<AgeGroup?> possibleAgeGroups =
      tournament.useAgeGroups ? ageGroups : [null];
  List<PlayingLevel?> possiblePlayingLevels =
      tournament.usePlayingLevels ? playingLevels : [null];

  return [
    for (AgeGroup? ageGroup in possibleAgeGroups)
      for (PlayingLevel? playingLevel in possiblePlayingLevels)
        PlayingCategory(ageGroup: ageGroup, playingLevel: playingLevel),
  ];
}

/// Groups the [competitions] into lists containing only competitions of the
/// same [CompetitionDiscipline].
///
/// Furthermore they are grouped into those of equal [PlayingCategory] but
/// with [ignoreAgeGroups] and [ignorePlayingLevels] applied.
List<List<Competition>> groupCompetitions(
  List<Competition> competitions, {
  bool ignoreAgeGroups = false,
  bool ignorePlayingLevels = false,
}) {
  Map<CompetitionDiscipline, List<Competition>> disciplineMap =
      competitions.groupListsBy(
    (c) => CompetitionDiscipline.fromCompetition(c),
  );

  Map<CompetitionDiscipline, Map<PlayingCategory, List<Competition>>>
      disciplineCategoryMap = disciplineMap.map(
    (CompetitionDiscipline discipline, List<Competition> competitions) =>
        MapEntry(
      discipline,
      competitions.groupListsBy(
        (competition) => PlayingCategory.fromCompetition(
          competition,
          ignoreAgeGroup: ignoreAgeGroups,
          ignorePlayingLevel: ignorePlayingLevels,
        ),
      ),
    ),
  );

  List<List<Competition>> competitionGroups = disciplineCategoryMap.values
      .expand((categoryMap) => categoryMap.values)
      .toList();

  return competitionGroups;
}

/// Maps which [CompetitionDiscipline]s exist in each [PlayingCategory].
///
/// Example: The O19 age group category
/// maps to [men's singles, women's singles].
///
/// It is the reverse mapping of [mapDisciplines].
Map<PlayingCategory, List<CompetitionDiscipline>> mapPlayingCategories(
  List<PlayingCategory> possibleCategories,
  List<Competition> competitions,
) {
  Map<PlayingCategory, List<CompetitionDiscipline>> existingCategories = {
    for (PlayingCategory category in possibleCategories) category: [],
  };

  for (Competition competition in competitions) {
    var competitionCategory =
        CompetitionDiscipline.fromCompetition(competition);
    var playingCategory = PlayingCategory.fromCompetition(competition);

    existingCategories[playingCategory]!.add(competitionCategory);
  }

  return existingCategories;
}

/// Maps which [PlayingCategory]s exist in each [CompetitionDiscipline]
///
/// Example: men's doubles maps to [O19, U19, U17].
///
/// It is the reverse mapping of [mapPlayingCategories].
Map<CompetitionDiscipline, List<PlayingCategory>> mapDisciplines(
  List<Competition> competitions,
) {
  Map<CompetitionDiscipline, List<PlayingCategory>> disciplineMap = {
    for (CompetitionDiscipline baseCompetition
        in CompetitionDiscipline.baseCompetitions)
      baseCompetition: [],
  };
  for (Competition competition in competitions) {
    var competitionDiscipline =
        CompetitionDiscipline.fromCompetition(competition);
    var playingCategory = PlayingCategory.fromCompetition(competition);

    disciplineMap[competitionDiscipline]!.add(playingCategory);
  }

  return disciplineMap;
}

/// Maps [Competition]s by one of their isolated categories [C].
///
/// [C] is either [AgeGroup] or [PlayingLevel] categorization.
///
/// Since competitions can be uncategorized by one of the categorizations, the
/// map key can be null.
Map<C?, List<Competition>> mapByCategory<C extends Model>(
  List<Competition> competitions,
) {
  assert(C == AgeGroup || C == PlayingLevel);
  Map<C?, List<Competition>> mappedCompetitions =
      competitions.groupListsBy((c) => getCompetitionCategory<C>(c));
  return mappedCompetitions;
}

/// Returns the specific category that the [competition] is under in the
/// categorization [C].
///
/// [C] is either [AgeGroup] or [PlayingLevel] categorization.
C? getCompetitionCategory<C extends Model>(Competition competition) {
  assert(C == AgeGroup || C == PlayingLevel);
  switch (C) {
    case AgeGroup:
      return competition.ageGroup as C?;
    case PlayingLevel:
      return competition.playingLevel as C?;
    default:
      return null;
  }
}
