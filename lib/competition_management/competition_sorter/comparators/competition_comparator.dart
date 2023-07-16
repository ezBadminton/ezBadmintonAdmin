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
      CompetitionDiscipline,
    ],
  });

  final List<Type> criteria;

  static const Map<Type, Comparator<Competition>> comparators = {
    AgeGroup: _compareAgeGroups,
    PlayingLevel: _comparePlayingLevels,
    CompetitionDiscipline: _compareCategories,
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
      CompetitionDiscipline,
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
    if (a.ageGroup == null || b.ageGroup == null) {
      return 0;
    }

    return compareAgeGroups(a.ageGroup!, b.ageGroup!);
  }

  static int _comparePlayingLevels(Competition a, Competition b) {
    if (a.playingLevel == null || b.playingLevel == null) {
      return 0;
    }

    return a.playingLevel!.index.compareTo(b.playingLevel!.index);
  }

  static int _compareCategories(Competition a, Competition b) {
    int indexA = CompetitionDiscipline.baseCompetitions
        .indexOf(CompetitionDiscipline.fromCompetition(a));
    int indexB = CompetitionDiscipline.baseCompetitions
        .indexOf(CompetitionDiscipline.fromCompetition(b));

    return indexA.compareTo(indexB);
  }

  static int _compareRegistrationCounts(Competition a, Competition b) {
    return a.registrations.length.compareTo(b.registrations.length);
  }
}
