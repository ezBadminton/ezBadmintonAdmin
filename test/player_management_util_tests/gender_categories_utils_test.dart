import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/utils/gender_categories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('opposite() extension method correctly return the opposite', () {
    expect(GenderCategory.female.opposite(), GenderCategory.male);
    expect(GenderCategory.male.opposite(), GenderCategory.female);
    expect(GenderCategory.any.opposite(), GenderCategory.any);
    expect(GenderCategory.mixed.opposite(), GenderCategory.mixed);
  });

  test(
    """isConflicting() extension method correctly identifies gender category
      conflicts""",
    () {
      expect(
        GenderCategory.female.isConflicting([GenderCategory.male]),
        true,
      );
      expect(
        GenderCategory.female.isConflicting([GenderCategory.female]),
        false,
      );
      expect(
        GenderCategory.male.isConflicting([GenderCategory.female]),
        true,
      );
      expect(
        GenderCategory.mixed.isConflicting([
          GenderCategory.female,
          GenderCategory.male,
        ]),
        false,
      );
    },
  );
}
