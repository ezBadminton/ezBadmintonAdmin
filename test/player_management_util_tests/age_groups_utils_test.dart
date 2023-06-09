import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/utils/age_groups.dart';
import 'package:flutter_test/flutter_test.dart';

var overAgeGroups = [10, 20, 30].map(
  (age) => AgeGroup(
    id: 'over$age',
    created: DateTime.now(),
    updated: DateTime.now(),
    age: age,
    type: AgeGroupType.over,
  ),
);

var underAgeGroups = [5, 9, 10, 12].map(
  (age) => AgeGroup(
    id: 'under$age',
    created: DateTime.now(),
    updated: DateTime.now(),
    age: age,
    type: AgeGroupType.under,
  ),
);

List<AgeGroup> shuffleAllAgeGroups() {
  return [...overAgeGroups, ...underAgeGroups]..shuffle();
}

void main() {
  group('AgeGroupAgeRange extension', () {
    test(
      """getAgeRange() correctly returns values:
      inclusive for over age, exclusive for under age,
      doesn't intersect with other age groups,
      limits of 0 or 999 at the lower/upper edges""",
      () {
        var allGroups = shuffleAllAgeGroups();
        expect(overAgeGroups.elementAt(0).getAgeRange(allGroups), [10, 19]);
        expect(overAgeGroups.elementAt(1).getAgeRange(allGroups), [20, 29]);
        expect(overAgeGroups.elementAt(2).getAgeRange(allGroups), [30, 999]);

        expect(underAgeGroups.elementAt(0).getAgeRange(allGroups), [0, 4]);
        expect(underAgeGroups.elementAt(1).getAgeRange(allGroups), [5, 8]);
        expect(underAgeGroups.elementAt(2).getAgeRange(allGroups), [9, 9]);
        expect(underAgeGroups.elementAt(3).getAgeRange(allGroups), [10, 11]);
      },
    );
  });

  test('ageToAgeGroups() returns the correct age groups', () {
    var allGroups = shuffleAllAgeGroups();
    expect(
      ageToAgeGroups(11, allGroups),
      allOf(
        hasLength(2),
        containsAll([
          overAgeGroups.elementAt(0),
          underAgeGroups.elementAt(3),
        ]),
      ),
    );
    expect(
      ageToAgeGroups(42, allGroups),
      [overAgeGroups.elementAt(2)],
    );
    expect(
      ageToAgeGroups(6, allGroups),
      [underAgeGroups.elementAt(1)],
    );
  });
}
