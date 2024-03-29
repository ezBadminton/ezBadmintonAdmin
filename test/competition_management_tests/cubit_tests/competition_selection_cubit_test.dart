import 'package:bloc_test/bloc_test.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_selection_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/models/competition_category.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common_matchers/state_matchers.dart';

class HasDisplayCompetitions extends CustomMatcher {
  HasDisplayCompetitions(matcher)
      : super(
          'State with display competitions',
          'List of Competitions',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.displayCompetitions;
}

class HasSelectionTristate extends CustomMatcher {
  HasSelectionTristate(matcher)
      : super(
          'State with selection tristate',
          'nullable boolean',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.selectionTristate;
}

List<Competition> competitions = CompetitionDiscipline.baseCompetitions
    .map(
      (discipline) => Competition.newCompetition(
        teamSize: discipline.competitionType == CompetitionType.singles ? 1 : 2,
        genderCategory: discipline.genderCategory,
      ).copyWith(
        id: '${discipline.genderCategory.name}${discipline.competitionType.name}',
      ),
    )
    .toList();

void main() {
  late CollectionRepository<Competition> competitionRepository;

  setUp(() {
    competitionRepository = TestCollectionRepository<Competition>();
  });

  CompetitionSelectionCubit createSut() {
    return CompetitionSelectionCubit(
      competitionRepository: competitionRepository,
    );
  }

  group('CompetitionSelectionCubit', () {
    test('initial state', () {
      CompetitionSelectionCubit sut = createSut();
      expect(sut.state, HasSelectedCompetitions(isEmpty));
      expect(sut.state, HasDisplayCompetitions(isEmpty));
    });

    blocTest<CompetitionSelectionCubit, CompetitionSelectionState>(
      'set display competitions',
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.displayCompetitionsChanged(competitions);
      },
      skip: 1,
      expect: () => [
        HasDisplayCompetitions(competitions),
      ],
    );

    blocTest<CompetitionSelectionCubit, CompetitionSelectionState>(
      'selection toggle',
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.displayCompetitionsChanged(competitions);
        cubit.competitionToggled(competitions[0]);
        cubit.competitionToggled(competitions[0]);
        cubit.competitionToggled(competitions[1]);
        cubit.competitionToggled(competitions[2]);
      },
      skip: 2,
      expect: () => [
        HasSelectedCompetitions([competitions[0]]),
        HasSelectedCompetitions(isEmpty),
        HasSelectedCompetitions([competitions[1]]),
        HasSelectedCompetitions([competitions[1], competitions[2]]),
      ],
    );

    blocTest<CompetitionSelectionCubit, CompetitionSelectionState>(
      'entire selection toggle',
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.displayCompetitionsChanged(competitions);
        cubit.allCompetitionsToggled();
        cubit.allCompetitionsToggled();
        cubit.competitionToggled(competitions[0]);
        cubit.allCompetitionsToggled();
      },
      skip: 2,
      expect: () => [
        allOf(
          HasSelectedCompetitions(containsAll(competitions)),
          HasSelectionTristate(true),
        ),
        allOf(
          HasSelectedCompetitions(isEmpty),
          HasSelectionTristate(false),
        ),
        allOf(
          HasSelectedCompetitions([competitions[0]]),
          HasSelectionTristate(null),
        ),
        allOf(
          HasSelectedCompetitions(containsAll(competitions)),
          HasSelectionTristate(true),
        ),
      ],
    );

    blocTest<CompetitionSelectionCubit, CompetitionSelectionState>(
      'selection removed from display list',
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.displayCompetitionsChanged(competitions);
        cubit.competitionToggled(competitions[0]);
        cubit.displayCompetitionsChanged(competitions.sublist(1));
      },
      skip: 2,
      expect: () => [
        HasSelectedCompetitions([competitions[0]]),
        HasSelectedCompetitions(isEmpty),
      ],
    );
  });
}
