import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:formz/formz.dart';

part 'call_out_state.dart';

class CallOutCubit extends CollectionQuerierCubit<CallOutState> {
  CallOutCubit({
    required CollectionRepository<MatchData> matchDataRepository,
  }) : super(
          collectionRepositories: [
            matchDataRepository,
          ],
          CallOutState(),
        );

  Future<void> calledOut(MatchData matchData) async {
    assert(matchData.court != null && matchData.startTime == null);

    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    MatchData matchDataWithStartTime =
        matchData.copyWith(startTime: DateTime.now().toUtc());

    MatchData? updatedMatchData =
        await querier.updateModel(matchDataWithStartTime);
    if (updatedMatchData == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  /// Cancel the ready for call out status of a match by reverting the court
  /// assignment in [matchData].
  void callOutCanceled(MatchData matchData) async {
    assert(matchData.court != null && matchData.startTime == null);

    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    MatchData matchDataWithoutCourt = matchData.copyWith(court: null);

    MatchData? updatedMatchData =
        await querier.updateModel(matchDataWithoutCourt);
    if (updatedMatchData == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }
}
