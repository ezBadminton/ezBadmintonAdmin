import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:formz/formz.dart';

mixin MatchCourtAssignmentQuery<S> on CollectionQuerierCubit<S> {
  Future<FormzSubmissionStatus> submitMatchCourtAssignment(
    MatchData matchData,
    Court court,
  ) async {
    DateTime now = DateTime.now().toUtc();

    MatchData matchWithCourt = matchData.copyWith(
      court: court,
      courtAssignmentTime: now,
    );

    MatchData? updatedMatch = await querier.updateModel(matchWithCourt);
    if (updatedMatch == null) {
      return FormzSubmissionStatus.failure;
    }

    return FormzSubmissionStatus.success;
  }
}
