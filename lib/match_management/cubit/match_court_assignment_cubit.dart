import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/match_management/cubit/match_start_stop_cubit.dart';
import 'package:formz/formz.dart';

part 'match_court_assignment_state.dart';

class MatchCourtAssignmentCubit extends Cubit<MatchCourtAssignmentState> {
  MatchCourtAssignmentCubit({
    required this.assignEndpoint,
    required this.unassignEndpoint,
  }) : super(MatchCourtAssignmentState());

  final AssignCourtEndpoint assignEndpoint;
  final UnassignCourtEndpoint unassignEndpoint;

  /// Assign the given [court] to [matchData].
  ///
  /// Afterwards the match is ready to start via [MatchStartStopCubit]'s
  /// functions.
  void courtAssignedToMatch(TournamentMatch matchData, Court court) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    try {
      await assignEndpoint.post(
        body: {"court": court.id},
        pathParams: {"matchdata": matchData.id},
      );
      emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
    } catch (_) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
    }
  }

  void courtAutoAssignedToMatch(TournamentMatch match) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    try {
      await assignEndpoint.post(
        pathParams: {"matchdata": match.id},
      );
      emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
    } catch (_) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
    }
  }

  /// Revoke the court that is assigned to [matchData] before the match started.
  void courtAssignmentRevoked(TournamentMatch matchData) async {
    assert(matchData.court != null && matchData.startTime == null);

    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    try {
      await unassignEndpoint.post(
        pathParams: {"matchdata": matchData.id},
      );
      emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
    } catch (_) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
    }
  }
}
