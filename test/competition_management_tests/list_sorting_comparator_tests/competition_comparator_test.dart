import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_sorter/comparators/competition_comparator.dart';
import 'package:ez_badminton_admin_app/competition_management/models/competition_category.dart';
import 'package:ez_badminton_admin_app/list_sorting/comparator/list_sorting_comparator.dart';
import 'package:flutter_test/flutter_test.dart';

List<AgeGroup> ageGroups = List.generate(
  3,
  (index) => AgeGroup.newAgeGroup(type: AgeGroupType.over, age: index)
      .copyWith(id: 'AgeGroup-$index'),
);

List<Competition> ageGroupCompetitions = ageGroups
    .map(
      (ageGroup) => Competition.newCompetition(
        teamSize: 2,
        genderCategory: GenderCategory.mixed,
        ageGroup: ageGroup,
      ).copyWith(id: 'AgeGroupCompetition-${ageGroup.id}'),
    )
    .toList();

List<PlayingLevel> playingLevels = List.generate(
  3,
  (index) => PlayingLevel.newPlayingLevel('PlayingLevel-$index', index)
      .copyWith(id: 'PlayingLevel-$index'),
);

List<Competition> playingLevelCompetitions = playingLevels
    .map(
      (playingLevel) => Competition.newCompetition(
        teamSize: 2,
        genderCategory: GenderCategory.mixed,
        playingLevel: playingLevel,
      ).copyWith(id: 'PlayingLevelCompetition-${playingLevel.id}'),
    )
    .toList();

List<Competition> baseDisciplineCompetitions = CompetitionDiscipline
    .baseCompetitions
    .map(
      (discipline) => Competition.newCompetition(
        teamSize: discipline.competitionType == CompetitionType.singles ? 1 : 2,
        genderCategory: discipline.genderCategory,
      ),
    )
    .toList();

List<Competition> competitionsWithRegistrations = List.generate(
  3,
  (registrationCount) => Competition.newCompetition(
    teamSize: 2,
    genderCategory: GenderCategory.mixed,
    registrations: List.generate(registrationCount, (_) => Team.newTeam()),
  ).copyWith(id: 'CompetitionWith${registrationCount}Teams'),
);

void main() {
  group('CompetitionComparator', () {
    test('compare by AgeGroup', () {
      CompetitionComparator<AgeGroup> sut = const CompetitionComparator(
        criteria: [
          AgeGroup,
        ],
      );

      List<Competition> ascending = List.of(ageGroupCompetitions)
        ..shuffle()
        ..sort(sut.copyWith(ComparatorMode.ascending).comparator);
      List<Competition> descending = List.of(ageGroupCompetitions)
        ..shuffle()
        ..sort(sut.copyWith(ComparatorMode.descending).comparator);

      expect(ascending, containsAllInOrder(ageGroupCompetitions.reversed));
      expect(descending, containsAllInOrder(ageGroupCompetitions));
    });

    test('compare by PlayingLevel', () {
      CompetitionComparator<PlayingLevel> sut = const CompetitionComparator(
        criteria: [
          PlayingLevel,
        ],
      );

      List<Competition> ascending = List.of(playingLevelCompetitions)
        ..shuffle()
        ..sort(sut.copyWith(ComparatorMode.ascending).comparator);
      List<Competition> descending = List.of(playingLevelCompetitions)
        ..shuffle()
        ..sort(sut.copyWith(ComparatorMode.descending).comparator);

      expect(ascending, containsAllInOrder(playingLevelCompetitions));
      expect(descending, containsAllInOrder(playingLevelCompetitions.reversed));
    });

    test('compare by CompetitionDiscipline', () {
      CompetitionComparator<CompetitionDiscipline> sut =
          const CompetitionComparator(
        criteria: [
          CompetitionDiscipline,
        ],
      );

      List<Competition> ascending = List.of(baseDisciplineCompetitions)
        ..shuffle()
        ..sort(sut.copyWith(ComparatorMode.ascending).comparator);
      List<Competition> descending = List.of(baseDisciplineCompetitions)
        ..shuffle()
        ..sort(sut.copyWith(ComparatorMode.descending).comparator);

      expect(ascending, containsAllInOrder(baseDisciplineCompetitions));
      expect(
        descending,
        containsAllInOrder(baseDisciplineCompetitions.reversed),
      );
    });

    test('compare by registration count (Teams)', () {
      CompetitionComparator<Team> sut = const CompetitionComparator(
        criteria: [
          Team,
        ],
      );

      List<Competition> ascending = List.of(competitionsWithRegistrations)
        ..shuffle()
        ..sort(sut.copyWith(ComparatorMode.ascending).comparator);
      List<Competition> descending = List.of(competitionsWithRegistrations)
        ..shuffle()
        ..sort(sut.copyWith(ComparatorMode.descending).comparator);

      expect(ascending, containsAllInOrder(competitionsWithRegistrations));
      expect(
        descending,
        containsAllInOrder(competitionsWithRegistrations.reversed),
      );
    });

    test('secondary comparison criterion', () {
      CompetitionComparator<Team> sut = const CompetitionComparator(
        criteria: [
          CompetitionDiscipline,
          Team,
        ],
      );

      List<Competition> ascending = List.of(competitionsWithRegistrations)
        ..shuffle()
        ..sort(sut.copyWith(ComparatorMode.ascending).comparator);
      List<Competition> descending = List.of(competitionsWithRegistrations)
        ..shuffle()
        ..sort(sut.copyWith(ComparatorMode.descending).comparator);

      expect(ascending, containsAllInOrder(competitionsWithRegistrations));
      expect(
        descending,
        containsAllInOrder(competitionsWithRegistrations.reversed),
      );
    });
  });
}
