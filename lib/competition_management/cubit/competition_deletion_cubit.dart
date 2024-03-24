import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:formz/formz.dart';

part 'competition_deletion_state.dart';

class CompetitionDeletionCubit
    extends CollectionQuerierCubit<CompetitionDeletionState>
    with DialogCubit<CompetitionDeletionState> {
  CompetitionDeletionCubit({
    required CollectionRepository<Competition> competitionRepository,
  }) : super(
          collectionRepositories: [
            competitionRepository,
          ],
          CompetitionDeletionState(),
        );

  void selectedCompetitionsChanged(List<Competition> selectedCompetitions) {
    emit(state.copyWith(
      selectedCompetitions: selectedCompetitions,
      isSelectionDeletable: _isSelectionDeletable(selectedCompetitions),
    ));
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
        await querier.deleteModels(state.selectedCompetitions);
    if (!competitionsDeleted) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  bool _isSelectionDeletable(List<Competition> selectedCompetitions) {
    if (selectedCompetitions.isEmpty) {
      return false;
    }

    bool areAllCompetitionsNotRunning = selectedCompetitions.firstWhereOrNull(
          (competition) => competition.matches.isNotEmpty,
        ) ==
        null;

    return areAllCompetitionsNotRunning;
  }

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    List<CollectionUpdateEvent<Model>> updateEvents,
  ) =>
      {};
}
