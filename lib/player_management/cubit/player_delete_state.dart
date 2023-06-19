// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:collection_repository/collection_repository.dart';
import 'package:formz/formz.dart';

class PlayerDeleteState {
  PlayerDeleteState({
    required this.player,
    this.formStatus = FormzSubmissionStatus.initial,
    this.showConfirmDialog = false,
  });

  final Player player;
  final FormzSubmissionStatus formStatus;
  final bool showConfirmDialog;

  PlayerDeleteState copyWith({
    Player? player,
    FormzSubmissionStatus? formStatus,
    bool? showConfirmDialog,
    Map<Type, List<Model>>? collections,
  }) {
    return PlayerDeleteState(
      player: player ?? this.player,
      formStatus: formStatus ?? this.formStatus,
      showConfirmDialog: showConfirmDialog ?? this.showConfirmDialog,
    );
  }
}
