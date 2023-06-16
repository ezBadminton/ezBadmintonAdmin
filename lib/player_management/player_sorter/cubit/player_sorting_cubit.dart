import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/list_sorting/cubit/list_sorting_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/comparators/club_comparator.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/comparators/name_comparator.dart';

class PlayerSortingCubit extends ListSortingCubit<Player> {
  PlayerSortingCubit({
    required super.defaultComparator,
    required NameComparator nameComparator,
    required ClubComparator clubComparator,
  }) : super(
          comparators: [
            nameComparator,
            clubComparator,
          ],
        );
}
