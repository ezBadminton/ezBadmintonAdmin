// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'bulk_player_status_cubit.dart';

class BulkPlayerStatusState {
  BulkPlayerStatusState({
    this.formStatus = FormzSubmissionStatus.initial,
    this.playerStatus = const SelectionInput.pure(),
  });

  final FormzSubmissionStatus formStatus;
  final SelectionInput<PlayerStatus> playerStatus;

  BulkPlayerStatusState copyWith({
    FormzSubmissionStatus? formStatus,
    SelectionInput<PlayerStatus>? playerStatus,
  }) {
    return BulkPlayerStatusState(
      formStatus: formStatus ?? this.formStatus,
      playerStatus: playerStatus ?? this.playerStatus,
    );
  }
}
