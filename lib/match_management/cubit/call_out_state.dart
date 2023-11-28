part of 'call_out_cubit.dart';

class CallOutState implements DialogState {
  CallOutState({
    this.formStatus = FormzSubmissionStatus.initial,
    this.dialog = const CubitDialog(),
  });

  final FormzSubmissionStatus formStatus;

  @override
  final CubitDialog dialog;

  CallOutState copyWith({
    FormzSubmissionStatus? formStatus,
    CubitDialog? dialog,
  }) {
    return CallOutState(
      formStatus: formStatus ?? this.formStatus,
      dialog: dialog ?? this.dialog,
    );
  }
}
