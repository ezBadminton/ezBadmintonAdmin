import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model_repository/model_repository.dart';
import 'package:formz/formz.dart';

part 'qualification_override_state.dart';

class QualificationOverrideCubit extends Cubit<QualificationOverrideState> {
  QualificationOverrideCubit({
    required this.competition,
    required this.overrideEndpoint,
    required this.overrideResetEndpoint,
  }) : super(QualificationOverrideState());

  final Competition competition;
  final QualificationOverrideSwapEndpoint overrideEndpoint;
  final QualificationOverrideResetEndpoint overrideResetEndpoint;

  void swapQualificationOverridePositions(Team a, Team b) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    try {
      await overrideEndpoint.post(
        pathParams: {"competition": competition.id},
        body: {
          "teamA": a.id,
          "teamB": b.id,
        },
      );
      emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
    } catch (_) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
    }
  }

  void resetQualificationOverride() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    try {
      await overrideResetEndpoint.delete(
        pathParams: {"competition": competition.id},
      );
      emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
    } catch (_) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
    }
  }
}
