// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'gymnasium_deletion_cubit.dart';

class GymnasiumDeletionState implements DialogState {
  GymnasiumDeletionState({
    required this.gymnasium,
    this.formStatus = FormzSubmissionStatus.initial,
    this.dialog = const CubitDialog(),
  });

  final Gymnasium gymnasium;

  final FormzSubmissionStatus formStatus;

  @override
  final CubitDialog dialog;

  GymnasiumDeletionState copyWith({
    Gymnasium? gymnasium,
    FormzSubmissionStatus? formStatus,
    CubitDialog? dialog,
  }) {
    return GymnasiumDeletionState(
      gymnasium: gymnasium ?? this.gymnasium,
      formStatus: formStatus ?? this.formStatus,
      dialog: dialog ?? this.dialog,
    );
  }
}
