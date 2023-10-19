part of 'call_out_cubit.dart';

class CallOutState {
  CallOutState({
    this.formStatus = FormzSubmissionStatus.initial,
  });

  final FormzSubmissionStatus formStatus;

  CallOutState copyWith({
    FormzSubmissionStatus? formStatus,
  }) {
    return CallOutState(
      formStatus: formStatus ?? this.formStatus,
    );
  }
}
