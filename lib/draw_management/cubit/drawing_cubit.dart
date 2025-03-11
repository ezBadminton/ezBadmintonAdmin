import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:formz/formz.dart';

part 'drawing_state.dart';

class DrawingCubit extends Cubit<DrawingState> with DialogCubit {
  DrawingCubit({
    required this.competition,
    required this.drawEndpoint,
    required this.redrawEndpoint,
    required this.swapEndpoint,
  }) : super(DrawingState());

  final Competition competition;
  final MakeDrawEndpoint drawEndpoint;
  final RedrawEndpoint redrawEndpoint;
  final SwapDrawEndpoint swapEndpoint;

  /// Make the draw using the existing [Competition.rngSeed]
  void makeDraw() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    try {
      await drawEndpoint.post(
        pathParams: {"competition": competition.id},
      );
      emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
    } catch (_) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
    }
  }

  /// Make the draw with a newly created RNG seed
  void redraw() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    try {
      await redrawEndpoint.post(
        pathParams: {"competition": competition.id},
      );
      emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
    } catch (_) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
    }
  }

  void swapDrawMembers(Team a, Team b) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    try {
      await swapEndpoint.post(
        pathParams: {"competition": competition.id},
        body: {
          "swap": [a.id, b.id]
        },
      );
      emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
    } catch (_) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
    }
  }
}
