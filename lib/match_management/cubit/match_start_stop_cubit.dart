import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:formz/formz.dart';

part 'match_start_stop_state.dart';

class MatchStartStopCubit extends Cubit<MatchStartStopState>
    with DialogCubit<MatchStartStopState> {
  MatchStartStopCubit({
    required this.startEndpoint,
    required this.cancelEndpoint,
  }) : super(MatchStartStopState());

  final StartMatchEndpoint startEndpoint;
  final CancelMatchEndpoint cancelEndpoint;

  Future<void> matchStarted(TournamentMatch matchData) async {
    assert(matchData.court != null && matchData.startTime == null);

    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    try {
      await startEndpoint.post(pathParams: {"matchdata": matchData.id});
      emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
    } catch (_) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
    }
  }

  void matchCanceled(TournamentMatch matchData) async {
    assert(matchData.startTime != null && matchData.sets.isEmpty);

    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    try {
      await cancelEndpoint.post(pathParams: {"matchdata": matchData.id});
      emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
    } catch (_) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
    }
  }

  /// Ends a match without a score being recorded.
  ///
  /// This frees the court for the next match. The score can be entered later.
  void matchEnded(TournamentMatch matchData) async {
    // TODO maybe
    /*
    assert(matchData.court != null &&
        matchData.startTime != null &&
        matchData.endTime == null);

    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    DateTime now = DateTime.now().toUtc();

    TournamentMatch matchDataWithEndTime = matchData.copyWith(endTime: now);

    TournamentMatch? updatedTournamentMatch =
        await querier.updateModel(matchDataWithEndTime);
    if (updatedTournamentMatch == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
    */
  }
}
