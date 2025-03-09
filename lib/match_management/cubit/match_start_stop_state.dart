part of 'match_start_stop_cubit.dart';

class MatchStartStopState implements DialogState {
  MatchStartStopState({
    this.formStatus = FormzSubmissionStatus.initial,
    this.dialog = const CubitDialog(),
  });

  final FormzSubmissionStatus formStatus;

  @override
  final CubitDialog dialog;

  MatchStartStopState copyWith({
    FormzSubmissionStatus? formStatus,
    CubitDialog? dialog,
  }) {
    return MatchStartStopState(
      formStatus: formStatus ?? this.formStatus,
      dialog: dialog ?? this.dialog,
    );
  }
}
