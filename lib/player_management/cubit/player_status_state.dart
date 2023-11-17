part of 'player_status_cubit.dart';

class PlayerStatusState implements DialogState {
  PlayerStatusState({
    required this.player,
    this.formStatus = FormzSubmissionStatus.initial,
    this.dialog = const CubitDialog(),
  });

  final Player player;
  final FormzSubmissionStatus formStatus;

  @override
  final CubitDialog dialog;

  PlayerStatusState copyWith({
    Player? player,
    FormzSubmissionStatus? formStatus,
    CubitDialog? dialog,
  }) =>
      PlayerStatusState(
        player: player ?? this.player,
        formStatus: formStatus ?? this.formStatus,
        dialog: dialog ?? this.dialog,
      );
}
