import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_sorter/comparators/competition_comparator.dart';
import 'package:ez_badminton_admin_app/court_management/court_list/utils/numbered_string.dart';

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

    competitions.sort(compareCompetitions);

    S updatedState = copyWithCollection(
      modelType: Competition,
      collection: competitions,
    );

    return updatedState;
  }

  S copyWithCourtSorting() {
    List<Court> courts = getCollection<Court>();

    courts.sort(compareCourts);

    S updatedState = copyWithCollection(
      modelType: Court,
      collection: courts,
    );

    return updatedState;
  }
}

final Comparator<Competition> compareCompetitions =
    const CompetitionComparator().comparator;

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

int compareCourts(Court court1, Court court2) {
  NumberedString gymName1 = NumberedString(court1.gymnasium.name);
  NumberedString gymName2 = NumberedString(court2.gymnasium.name);
  NumberedString courtName1 = NumberedString(court1.name);
  NumberedString courtName2 = NumberedString(court2.name);

  int gymComparison = gymName1.compareTo(gymName2);
  if (gymComparison != 0) {
    return gymComparison;
  }

  return courtName1.compareTo(courtName2);
}

int compareMatches(BadmintonMatch match1, BadmintonMatch match2) {
  List<BadmintonMatch> matches1 = match1.round!.tournament.matches.cast();
  List<BadmintonMatch> matches2 = match2.round!.tournament.matches.cast();

  int matchIndex1 = matches1.indexOf(match1);
  int matchIndex2 = matches2.indexOf(match2);

  assert(matchIndex1 != -1 && matchIndex2 != -1);

  int matchIndexComparison = matchIndex1.compareTo(matchIndex2);

  if (matchIndexComparison != 0) {
    return matchIndexComparison;
  }

  int competitionComparison =
      compareCompetitions(match1.competition, match2.competition);

  return competitionComparison;
}
