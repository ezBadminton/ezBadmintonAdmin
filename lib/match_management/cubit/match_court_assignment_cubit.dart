import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
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

  void assignMatchToCourt(MatchData matchData, Court court) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    FormzSubmissionStatus assignmentStatus =
        await submitMatchCourtAssignment(matchData, court);

    emit(state.copyWith(formStatus: assignmentStatus));
  }
}
