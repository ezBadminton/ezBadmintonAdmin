import 'package:collection_repository/collection_repository.dart';

extension GenderCategoryConflict on GenderCategory {
  /// Returns true if [otherCategories] contains a [GenderCategory] that
  /// conflicts with this [GenderCategory].
  ///
  /// Only [GenderCategory.female] and [GenderCategory.male] cause conflicts
  /// with each other.
  bool isConflicting(Iterable<GenderCategory> otherCategories) {
    return (this == GenderCategory.female &&
            otherCategories.contains(GenderCategory.male)) ||
        (this == GenderCategory.male &&
            otherCategories.contains(GenderCategory.female));
  }

  /// Turns [GenderCategory.female] into [GenderCategory.male] and vice versa.
  ///
  /// Other [GenderCategory]s are just returned.
  GenderCategory opposite() {
    if (this == GenderCategory.female) {
      return GenderCategory.male;
    }
    if (this == GenderCategory.male) {
      return GenderCategory.female;
    }
    return this;
  }
}
