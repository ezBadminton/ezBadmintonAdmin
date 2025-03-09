part of 'result_deletion_cubit.dart';

class ResultDeletionState implements DialogState {
  ResultDeletionState({
    this.formStatus = FormzSubmissionStatus.initial,
    this.dialog = const CubitDialog(),
  });

  final FormzSubmissionStatus formStatus;

  @override
  final CubitDialog dialog;

  ResultDeletionState copyWith({
    FormzSubmissionStatus? formStatus,
    CubitDialog? dialog,
  }) {
    return ResultDeletionState(
      formStatus: formStatus ?? this.formStatus,
      dialog: dialog ?? this.dialog,
    );
  }
}
