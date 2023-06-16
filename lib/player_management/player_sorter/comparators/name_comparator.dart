import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/list_sorting/comparator/list_sorting_comparator.dart';

class NameComparator extends ListSortingComparator<Player> {
  NameComparator({
    super.comparator,
    super.mode,
  });

  @override
  NameComparator copyWith(ComparatorMode mode) {
    Comparator<Player> comparator = (a, b) {
      return _getLastNameFirstName(a).compareTo(
        _getLastNameFirstName(b),
      );
    };

    if (mode == ComparatorMode.descending) {
      comparator = reverseComparator(comparator);
    }

    return NameComparator(comparator: comparator, mode: mode);
  }

  String _getLastNameFirstName(Player player) {
    return '${player.lastName}${player.firstName}';
  }
}
