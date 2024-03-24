import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_sorter/comparators/competition_comparator.dart';
import 'package:ez_badminton_admin_app/court_management/court_list/utils/numbered_string.dart';

final Comparator<Competition> compareCompetitions =
    const CompetitionComparator().comparator;

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

int compareCourts(Court court1, Court court2) {
  NumberedString gymName1 = NumberedString(court1.gymnasium.name);
  NumberedString gymName2 = NumberedString(court2.gymnasium.name);
  NumberedString courtName1 = NumberedString(court1.name);
  NumberedString courtName2 = NumberedString(court2.name);

  int gymComparison = gymName1.compareTo(gymName2);
  if (gymComparison != 0) {
    return gymComparison;
  }

  return courtName1.compareTo(courtName2);
}
