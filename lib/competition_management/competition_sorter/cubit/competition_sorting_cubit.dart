import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_sorter/comparators/competition_comparator.dart';
import 'package:ez_badminton_admin_app/competition_management/models/competition_category.dart';
import 'package:ez_badminton_admin_app/list_sorting/cubit/list_sorting_cubit.dart';

class CompetitionSortingCubit extends ListSortingCubit<Competition> {
  CompetitionSortingCubit({
    required CompetitionComparator<AgeGroup> ageGroupComparator,
    required CompetitionComparator<PlayingLevel> playingLevelComparator,
    required CompetitionComparator<CompetitionCategory> categoryComparator,
    required CompetitionComparator<Team> registrationComparator,
  }) : super(
          comparators: [
            ageGroupComparator,
            playingLevelComparator,
            categoryComparator,
            registrationComparator,
          ],
          defaultComparator: const CompetitionComparator(),
        );
}
