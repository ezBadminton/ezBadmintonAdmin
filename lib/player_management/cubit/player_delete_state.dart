// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/widgets/confirm_dialog/cubit_mixin/dialog_cubit.dart';
import 'package:formz/formz.dart';

class PlayerDeleteState implements DialogState {
  PlayerDeleteState({
    required this.player,
    this.formStatus = FormzSubmissionStatus.initial,
    this.dialog = const CubitDialog(),
  });

  final Player player;
  final FormzSubmissionStatus formStatus;

  @override
  final CubitDialog dialog;

  PlayerDeleteState copyWith({
    Player? player,
    FormzSubmissionStatus? formStatus,
    CubitDialog? dialog,
    Map<Type, List<Model>>? collections,
  }) {
    return PlayerDeleteState(
      player: player ?? this.player,
      formStatus: formStatus ?? this.formStatus,
      dialog: dialog ?? this.dialog,
    );
  }
}
