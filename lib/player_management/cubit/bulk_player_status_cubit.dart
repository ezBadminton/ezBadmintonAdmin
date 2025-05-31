import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:model_repository/model_repository.dart';

part 'bulk_player_status_state.dart';

class BulkPlayerStatusCubit extends Cubit<BulkPlayerStatusState> {
  BulkPlayerStatusCubit({
    required this.players,
    required this.bulkStatusEndpoint,
  }) : super(BulkPlayerStatusState());

  final List<Player> players;
  final BulkPlayerStatusEndpoint bulkStatusEndpoint;

  void statusChanged(PlayerStatus? status) {
    emit(
      state.copyWith(
        playerStatus: SelectionInput.dirty(
          emptyAllowed: true,
          value: status,
        ),
      ),
    );
  }

  void submitBulkPlayerStatus() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress ||
        state.playerStatus.value == null) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    try {
      await bulkStatusEndpoint.post(body: {
        "status": state.playerStatus.value!.index,
        "players": players.map((p) => p.id).toList(),
      });
    } catch (_) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }
}
