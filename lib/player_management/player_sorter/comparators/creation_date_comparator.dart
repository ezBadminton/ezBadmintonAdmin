import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/list_sorting/comparator/list_sorting_comparator.dart';

class CreationDateComparator extends ListSortingComparator<Player> {
  const CreationDateComparator();

  @override
  Comparator<Player> get comparator =>
      (Player a, Player b) => b.created.compareTo(a.created);

  @override
  ComparatorMode get mode => throw UnimplementedError();

  @override
  CreationDateComparator copyWith(ComparatorMode mode) => this;
}
