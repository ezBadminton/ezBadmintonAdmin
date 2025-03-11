import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model_repository/model_repository.dart';
import 'package:formz/formz.dart';

part 'draw_deletion_state.dart';

class DrawDeletionCubit extends Cubit<DrawDeletionState> {
  DrawDeletionCubit({
    required this.competition,
    required this.deleteEndpoint,
  }) : super(DrawDeletionState());

  final DeleteDrawEndpoint deleteEndpoint;
  final Competition competition;

  void deleteDraw() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    try {
      await deleteEndpoint.delete(pathParams: {"competition": competition.id});
      emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
    } catch (_) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
    }
  }
}
