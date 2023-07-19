import 'package:ez_badminton_admin_app/player_management/player_sorter/comparators/club_comparator.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/comparators/creation_date_comparator.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/comparators/name_comparator.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/cubit/player_sorting_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const CreationDateComparator defaultComparator = CreationDateComparator();
  final NameComparator nameComparator = NameComparator();
  final ClubComparator clubComparator = ClubComparator(
    secondaryComparator: defaultComparator.comparator,
  );

  PlayerSortingCubit createSut() {
    return PlayerSortingCubit(
      defaultComparator: defaultComparator,
      nameComparator: nameComparator,
      clubComparator: clubComparator,
    );
  }

  group('PlayerSortingCubit', () {
    test('inital state', () {
      PlayerSortingCubit sut = createSut();
      expect(sut.state, defaultComparator);
      expect(sut.getComparator<NameComparator>(), nameComparator);
      expect(sut.getComparator<ClubComparator>(), clubComparator);
      expect(
        () => sut.getComparator<CreationDateComparator>(),
        throwsAssertionError,
      );
    });
  });
}
