import 'package:model_repository/model_repository.dart';

final Comparator<Competition> compareCompetitions = (a, b) => 0;

int compareAgeGroups(AgeGroup ageGroup1, AgeGroup ageGroup2) {
  int typeIndex1 = AgeGroupType.values.indexOf(ageGroup1.type);
  int typeIndex2 = AgeGroupType.values.indexOf(ageGroup2.type);
  // Sort by age group type over < under
  int typeComparison = typeIndex1.compareTo(typeIndex2);

  if (typeComparison != 0) {
    return typeComparison;
  }

  // Sort by age descending
  int ageComparison = ageGroup2.age.compareTo(ageGroup1.age);
  return ageComparison;
}

int comparePlayingLevels(
    PlayingLevel playingLevel1, PlayingLevel playingLevel2) {
  return playingLevel1.index.compareTo(playingLevel2.index);
}
