import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';

/// Returns all the age groups that the given [age] fits in
List<AgeGroup> ageToAgeGroups(int age, List<AgeGroup> allGroups) {
  return allGroups.where((group) {
    var ageRange = getAgeRange(group, allGroups);
    return age >= ageRange[0] && age <= ageRange[1];
  }).toList();
}

/// Returns a 2-element list of [lower age limit, upper age limit] inclusive.
List<int> getAgeRange(AgeGroup ageGroup, List<AgeGroup> allGroups) {
  assert(allGroups.contains(ageGroup));
  var sortedGroups = allGroups
      .where((g) => g.type == ageGroup.type)
      .sorted((a, b) => a.age.compareTo(b.age));
  if (ageGroup.type == AgeGroupType.over) {
    sortedGroups = sortedGroups.reversed.toList();
  }

  var index = sortedGroups.indexOf(ageGroup);

  int limit1 = ageGroup.age - (ageGroup.type == AgeGroupType.under ? 1 : 0);
  int limit2;
  if (index == 0) {
    limit2 = ageGroup.type == AgeGroupType.under ? 0 : 999;
  } else {
    limit2 = sortedGroups[index - 1].age -
        (ageGroup.type == AgeGroupType.over ? 1 : 0);
  }

  return ageGroup.type == AgeGroupType.over
      ? [limit1, limit2]
      : [limit2, limit1];
}
