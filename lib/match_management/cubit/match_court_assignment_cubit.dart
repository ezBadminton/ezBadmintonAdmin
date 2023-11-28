import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/match_management/cubit/match_start_stop_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/cubit/mixins/match_court_assignment_query.dart';
import 'package:formz/formz.dart';

part 'match_court_assignment_state.dart';

class MatchCourtAssignmentCubit
    extends CollectionQuerierCubit<MatchCourtAssignmentState>
    with MatchCourtAssignmentQuery {
  MatchCourtAssignmentCubit({
    required CollectionRepository<MatchData> matchDataRepository,
  }) : super(
          collectionRepositories: [
            matchDataRepository,
          ],
          MatchCourtAssignmentState(),
        );

  /// Assign the given [court] to [matchData].
  ///
  /// Afterwards the match is ready to start via [MatchStartStopCubit]'s
  /// functions.
  void courtAssignedToMatch(MatchData matchData, Court court) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    FormzSubmissionStatus assignmentStatus =
        await submitMatchCourtAssignment(matchData, court);

    emit(state.copyWith(formStatus: assignmentStatus));
  }

  /// Revoke the court that is assigned to [matchData] before the match started.
  void courtAssignmentRevoked(MatchData matchData) async {
    assert(matchData.court != null && matchData.startTime == null);

    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    MatchData matchDataWithoutCourt = matchData.copyWith(
      court: null,
      courtAssignmentTime: null,
    );

    MatchData? updatedMatchData =
        await querier.updateModel(matchDataWithoutCourt);
    if (updatedMatchData == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }
}
