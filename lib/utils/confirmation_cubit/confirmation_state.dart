part of 'confirmation_cubit.dart';

class ConfirmationState implements DialogState {
  ConfirmationState({
    this.dialog = const CubitDialog(),
  });

  @override
  final CubitDialog dialog;

  ConfirmationState copyWith({
    CubitDialog? dialog,
  }) =>
      ConfirmationState(
        dialog: dialog ?? this.dialog,
      );
}
