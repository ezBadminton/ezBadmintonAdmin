import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/competition_management/utils/competition_queries.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:formz/formz.dart';

part 'competition_deletion_state.dart';

class CompetitionDeletionCubit
    extends CollectionQuerierCubit<CompetitionDeletionState>
    with DialogCubit<CompetitionDeletionState>, CompetitionDeletionQueries {
  CompetitionDeletionCubit({
    required CollectionRepository<Competition> competitionRepository,
    required CollectionRepository<Team> teamRepository,
  }) : super(
          collectionRepositories: [
            competitionRepository,
            teamRepository,
          ],
          CompetitionDeletionState(),
        );

  void selectedCompetitionsChanged(List<Competition> selectedCompetitions) {
    emit(state.copyWith(selectedCompetitions: selectedCompetitions));
  }

  void deleteSelectedCompetitions() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    bool teamsWillBeDeleted = state.selectedCompetitions
        .map((c) => c.registrations.isNotEmpty)
        .contains(true);

    bool userConfirmation = (await requestDialogChoice<bool>(
      reason: teamsWillBeDeleted,
    ))!;
    if (!userConfirmation) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.canceled));
      return;
    }

    bool competitionsDeleted =
        await deleteCompetitions(state.selectedCompetitions);
    if (!competitionsDeleted) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }
}
