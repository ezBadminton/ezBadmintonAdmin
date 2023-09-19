import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_sorter/comparators/competition_comparator.dart';

extension CollectionSorting<S extends CollectionFetcherState<S>>
    on CollectionFetcherState<S> {
  /// Copies the [CollectionFetcherState] with the [AgeGroup]
  /// collection sorted by [compareAgeGroups].
  ///
  /// Only works on a state that holds the [AgeGroup] collection.
  S copyWithAgeGroupSorting() {
    List<AgeGroup> ageGroups = getCollection<AgeGroup>();

    ageGroups.sort(compareAgeGroups);
    S updatedState = copyWithCollection(
      modelType: AgeGroup,
      collection: ageGroups,
    );

    return updatedState;
  }

  /// Copies the [CollectionFetcherState] with the [PlayingLevel]
  /// collection sorted by the [PlayingLevel] index.
  ///
  /// Only works on a state that holds the [PlayingLevel] collection.
  S copyWithPlayingLevelSorting() {
    List<PlayingLevel> playingLevels = getCollection<PlayingLevel>();

    playingLevels.sortBy<num>((element) => element.index);

    S updatedState = copyWithCollection(
      modelType: PlayingLevel,
      collection: playingLevels,
    );

    return updatedState;
  }

  /// Copies the [CollectionFetcherState] with the [Competition]
  /// collection sorted by the default [CompetitionComparator].
  ///
  /// Only works on a state that holds the [Competition] collection.
  S copyWithCompetitionSorting() {
    List<Competition> competitions = getCollection<Competition>();
    Comparator<Competition> comparator =
        const CompetitionComparator().comparator;

    competitions.sortByCompare((c) => c, comparator);

    S updatedState = copyWithCollection(
      modelType: Competition,
      collection: competitions,
    );

    return updatedState;
  }
}

int compareAgeGroups(AgeGroup ageGroup1, AgeGroup ageGroup2) {
  int typeIndex1 = AgeGroupType.values.indexOf(ageGroup1.type);
  int typeIndex2 = AgeGroupType.values.indexOf(ageGroup2.type);
  // Sort by age group type over < under
  int typeComparison = typeIndex1.compareTo(typeIndex2);

  if (typeComparison != 0) {
    return typeComparison;
  }

  // Sort by age descending
  int ageComparison = ageGroup2.age.compareTo(ageGroup1.age);
  return ageComparison;
}
