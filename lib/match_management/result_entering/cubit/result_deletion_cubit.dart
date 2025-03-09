import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:formz/formz.dart';

part 'result_deletion_state.dart';

class ResultDeletionCubit extends Cubit<ResultDeletionState>
    with DialogCubit<ResultDeletionState> {
  ResultDeletionCubit({
    required this.match,
    required this.resetEndpoint,
  }) : super(ResultDeletionState());

  final TournamentMatch match;
  final ResetMatchEndpoint resetEndpoint;

  void resultDeleted() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    bool userConfirmation = (await requestDialogChoice<bool>())!;
    if (!userConfirmation) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.canceled));
      return;
    }

    try {
      await resetEndpoint.post(pathParams: {"matchdata": match.id});
      emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
    } catch (_) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
    }
  }
}
