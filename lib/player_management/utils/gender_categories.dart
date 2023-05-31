import 'package:collection_repository/collection_repository.dart';

extension GenderCategoryConflict on GenderCategory {
  bool isConflicting(Iterable<GenderCategory> otherCategories) {
    return (this == GenderCategory.female &&
            otherCategories.contains(GenderCategory.male)) ||
        (this == GenderCategory.male &&
            otherCategories.contains(GenderCategory.female));
  }

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
