import 'package:bloc_test/bloc_test.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_deletion_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/models/competition_category.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';

import '../../common_matchers/state_matchers.dart';

Team team = Team.newTeam().copyWith(id: 'testteam');

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

Competition competitionWithTeam = Competition.newCompetition(
    teamSize: 2,
    genderCategory: GenderCategory.mixed,
    registrations: [team]).copyWith(id: 'team-competition');

void main() {
  late CollectionRepository<Competition> competitionRepository;
  late CollectionRepository<Team> teamRepository;

  void arrangeRepositories({
    bool throwing = false,
    List<Competition> competitions = const [],
    List<Team> teams = const [],
  }) {
    competitionRepository = TestCollectionRepository(
      initialCollection: competitions,
      throwing: throwing,
    );
    teamRepository = TestCollectionRepository(
      initialCollection: teams,
      throwing: throwing,
    );
  }

  CompetitionDeletionCubit createSut() {
    return CompetitionDeletionCubit(
      competitionRepository: competitionRepository,
      teamRepository: teamRepository,
    );
  }

  setUp(() {
    arrangeRepositories();
  });

  group('CompetitionDeletionCubit', () {
    test('initial state', () {
      CompetitionDeletionCubit sut = createSut();
      expect(sut.state, HasFormStatus(FormzSubmissionStatus.initial));
      expect(sut.state, HasDialog(HasDialogCompleter(isNull)));
      expect(sut.state, HasSelectedCompetitions(isEmpty));
    });

    blocTest<CompetitionDeletionCubit, CompetitionDeletionState>(
      'set selected competitions',
      build: createSut,
      act: (cubit) {
        cubit.selectedCompetitionsChanged(competitions);
      },
      expect: () => [
        HasSelectedCompetitions(competitions),
      ],
    );

    blocTest<CompetitionDeletionCubit, CompetitionDeletionState>(
      'cancel warning dialog',
      setUp: () {
        arrangeRepositories(
          competitions: competitions,
        );
      },
      build: createSut,
      act: (cubit) async {
        cubit.selectedCompetitionsChanged(competitions);
        cubit.deleteSelectedCompetitions();
        cubit.state.dialog.decisionCompleter!.complete(false);
      },
      skip: 1,
      expect: () => [
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasDialog(allOf(
          isA<CubitDialog<bool>>(),
          HasDialogReason(false),
        )),
        HasFormStatus(FormzSubmissionStatus.canceled),
      ],
      verify: (_) async {
        List<Competition> collection = await competitionRepository.getList();
        expect(collection, containsAll(competitions));
      },
    );

    blocTest<CompetitionDeletionCubit, CompetitionDeletionState>(
      'deletion with warning dialog',
      setUp: () {
        arrangeRepositories(
          competitions: [...competitions, competitionWithTeam],
          teams: [team],
        );
      },
      build: createSut,
      act: (cubit) async {
        cubit.selectedCompetitionsChanged(competitions);
        cubit.deleteSelectedCompetitions();
        cubit.state.dialog.decisionCompleter!.complete(true);

        await Future.delayed(Duration.zero);

        cubit.selectedCompetitionsChanged([competitionWithTeam]);
        cubit.deleteSelectedCompetitions();
        cubit.state.dialog.decisionCompleter!.complete(true);
      },
      skip: 1,
      expect: () => [
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasDialog(allOf(
          isA<CubitDialog<bool>>(),
          HasDialogReason(false),
        )),
        HasFormStatus(FormzSubmissionStatus.success),
        HasSelectedCompetitions([competitionWithTeam]),
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasDialog(allOf(
          isA<CubitDialog<bool>>(),
          HasDialogReason(true),
        )),
        HasFormStatus(FormzSubmissionStatus.success),
      ],
      verify: (_) async {
        List<Competition> competitionCollection =
            await competitionRepository.getList();
        expect(competitionCollection, isEmpty);

        List<Team> teamCollection = await teamRepository.getList();
        expect(teamCollection, isEmpty);
      },
    );
  });
}
