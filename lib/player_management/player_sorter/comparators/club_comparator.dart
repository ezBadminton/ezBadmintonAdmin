import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/list_sorting/comparator/list_sorting_comparator.dart';

class ClubComparator extends ListSortingComparator<Player> {
  ClubComparator({
    super.comparator,
    super.mode,
    required this.secondaryComparator,
  });

  final Comparator<Player> secondaryComparator;

  @override
  ClubComparator copyWith(ComparatorMode mode) {
    Comparator<Player> comparator = (a, b) {
      if (a.club == b.club) {
        return 0;
      } else if (a.club == null) {
        return 1;
      } else if (b.club == null) {
        return -1;
      } else {
        return a.club!.name.compareTo(b.club!.name);
      }
    };

    if (mode == ComparatorMode.descending) {
      comparator = reverseComparator(comparator);
    }

    comparatorWithSecondary(a, b) {
      int result = comparator(a, b);
      if (result == 0) {
        return secondaryComparator(a, b);
      } else {
        return result;
      }
    }

    return ClubComparator(
      comparator: comparatorWithSecondary,
      mode: mode,
      secondaryComparator: secondaryComparator,
    );
  }
}
