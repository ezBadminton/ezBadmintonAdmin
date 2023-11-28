import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:formz/formz.dart';

part 'call_out_state.dart';

class CallOutCubit extends CollectionQuerierCubit<CallOutState>
    with DialogCubit<CallOutState> {
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

    DateTime now = DateTime.now().toUtc();
    MatchData matchWithStartTime = matchData.copyWith(startTime: now);

    MatchData? updatedMatch = await querier.updateModel(matchWithStartTime);
    if (updatedMatch == null) {
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

  void matchCanceled(MatchData matchData) async {
    assert(matchData.court != null &&
        matchData.startTime != null &&
        matchData.endTime == null);

    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    DateTime now = DateTime.now().toUtc();

    Duration matchDuration = now.difference(matchData.startTime!);

    if (matchDuration.inMinutes >= 1) {
      bool userConfirmation = (await requestDialogChoice<bool>())!;

      if (!userConfirmation) {
        emit(state.copyWith(formStatus: FormzSubmissionStatus.canceled));
        return;
      }
    }

    MatchData matchDataWithoutStartTime = matchData.copyWith(
      startTime: null,
      endTime: null,
    );

    MatchData? updatedMatchData =
        await querier.updateModel(matchDataWithoutStartTime);
    if (updatedMatchData == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  void matchEnded(MatchData matchData) async {
    assert(matchData.court != null &&
        matchData.startTime != null &&
        matchData.endTime == null);

    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    DateTime now = DateTime.now().toUtc();

    MatchData matchDataWithEndTime = matchData.copyWith(endTime: now);

    MatchData? updatedMatchData =
        await querier.updateModel(matchDataWithEndTime);
    if (updatedMatchData == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }
}
