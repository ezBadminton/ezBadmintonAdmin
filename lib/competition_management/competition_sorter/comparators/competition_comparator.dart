import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/models/competition_category.dart';
import 'package:ez_badminton_admin_app/competition_management/utils/sorting.dart';
import 'package:ez_badminton_admin_app/list_sorting/comparator/list_sorting_comparator.dart';

class CompetitionComparator<C extends Object>
    extends ListSortingComparator<Competition> {
  const CompetitionComparator({
    super.comparator = _compareCompetitions,
    super.mode,
    this.criteria = const [
      AgeGroup,
      PlayingLevel,
      CompetitionCategory,
    ],
  });

  final List<Type> criteria;

  static const Map<Type, Comparator<Competition>> comparators = {
    AgeGroup: _compareAgeGroups,
    PlayingLevel: _comparePlayingLevels,
    CompetitionCategory: _compareCategories,
    Team: _compareRegistrationCounts,
  };

  @override
  CompetitionComparator<C> copyWith(ComparatorMode mode) {
    Comparator<Competition> comparator = (a, b) => _compareCompetitions(
          a,
          b,
          criteria: criteria,
        );

    if (mode == ComparatorMode.descending) {
      comparator = reverseComparator(comparator);
    }

    return CompetitionComparator<C>(
      comparator: comparator,
      mode: mode,
      criteria: criteria,
    );
  }

  static int _compareCompetitions(
    Competition a,
    Competition b, {
    List<Type> criteria = const [
      AgeGroup,
      PlayingLevel,
      CompetitionCategory,
    ],
  }) {
    Comparator<Competition> comparator = criteria.fold(
      (a, b) => 0,
      (previousValue, element) =>
          nestComparators(previousValue, comparators[element]!),
    );
    return comparator(a, b);
  }

  static int _compareAgeGroups(Competition a, Competition b) {
    if (a.ageGroups.isEmpty || b.ageGroups.isEmpty) {
      return 0;
    }

    return compareAgeGroups(a.ageGroups.first, b.ageGroups.first);
  }

  static int _comparePlayingLevels(Competition a, Competition b) {
    if (a.playingLevels.isEmpty || b.playingLevels.isEmpty) {
      return 0;
    }

    return a.playingLevels.first.index.compareTo(b.playingLevels.first.index);
  }

  static int _compareCategories(Competition a, Competition b) {
    int indexA = CompetitionCategory.defaultCompetitions
        .indexOf(CompetitionCategory.fromCompetition(a));
    int indexB = CompetitionCategory.defaultCompetitions
        .indexOf(CompetitionCategory.fromCompetition(b));

    return indexA.compareTo(indexB);
  }

  static int _compareRegistrationCounts(Competition a, Competition b) {
    return a.registrations.length.compareTo(b.registrations.length);
  }
}
