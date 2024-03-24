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

  void arrangeRepositories({
    bool throwing = false,
    List<Competition> competitions = const [],
  }) {
    competitionRepository = TestCollectionRepository(
      initialCollection: competitions,
      throwing: throwing,
    );
  }

  CompetitionDeletionCubit createSut() {
    return CompetitionDeletionCubit(
      competitionRepository: competitionRepository,
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
      verify: (_) {
        List<Competition> collection = competitionRepository.getList();
        expect(collection, containsAll(competitions));
      },
    );

    blocTest<CompetitionDeletionCubit, CompetitionDeletionState>(
      'deletion with warning dialog',
      setUp: () {
        arrangeRepositories(
          competitions: [...competitions, competitionWithTeam],
        );
      },
      build: createSut,
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 2));

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
      verify: (_) {
        List<Competition> competitionCollection =
            competitionRepository.getList();
        expect(competitionCollection, isEmpty);
      },
    );
  });
}
