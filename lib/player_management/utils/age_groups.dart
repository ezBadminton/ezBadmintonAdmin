import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';

/// Returns all the age groups that the given [age] fits in
List<AgeGroup> ageToAgeGroups(int age, List<AgeGroup> allGroups) {
  return allGroups.where((group) {
    var ageRange = group.getAgeRange(allGroups);
    return age >= ageRange[0] && age <= ageRange[1];
  }).toList();
}

extension AgeGroupAgeRange on AgeGroup {
  /// Returns a 2-element list of [lower age limit, upper age limit] inclusive.
  ///
  /// At the edges of the age groups the limits are `0` and `999` respectively.
  List<int> getAgeRange(List<AgeGroup> allGroups) {
    assert(allGroups.contains(this));
    var sortedGroups = allGroups
        .where((g) => g.type == type)
        .sorted((a, b) => a.age.compareTo(b.age));
    if (type == AgeGroupType.over) {
      sortedGroups = sortedGroups.reversed.toList();
    }

    var index = sortedGroups.indexOf(this);

    int limit1 = age - (type == AgeGroupType.under ? 1 : 0);
    int limit2;
    if (index == 0) {
      limit2 = type == AgeGroupType.under ? 0 : 999;
    } else {
      limit2 =
          sortedGroups[index - 1].age - (type == AgeGroupType.over ? 1 : 0);
    }

    return type == AgeGroupType.over ? [limit1, limit2] : [limit2, limit1];
  }
}
