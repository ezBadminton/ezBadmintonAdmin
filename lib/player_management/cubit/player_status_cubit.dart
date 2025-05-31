import 'package:collection/collection.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:formz/formz.dart';

part 'player_status_state.dart';

class PlayerStatusCubit extends CollectionQuerierCubit<PlayerStatusState>
    with DialogCubit {
  PlayerStatusCubit({
    required Player player,
    required ModelStore<Player> playerStore,
    required ModelStore<TournamentMatch> matchStore,
    required this.previewEndpoint,
    required this.statusEndpoint,
  }) : super(
          PlayerStatusState(player: player),
          modelStores: [
            playerStore,
            matchStore,
          ],
        ) {
    subscribeToCollectionUpdates(playerStore, _onPlayerUpdated);
  }

  final WithdrawalPreviewEndpoint previewEndpoint;
  final PlayerStatusEndpoint statusEndpoint;

  void statusChanged(PlayerStatus status) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    try {
      FormzSubmissionStatus formStatus = await _confirmThenSetStatus(status);
      emit(state.copyWith(formStatus: formStatus));
    } catch (e) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
    }
  }

  Future<FormzSubmissionStatus> _confirmThenSetStatus(
    PlayerStatus status,
  ) async {
    var statusIndex = status.index;
    WithdrawalPreview preview = await previewEndpoint.get(pathParams: {
      "player": state.player.id,
      "status": statusIndex.toString(),
    });
    var walkovers = preview.changes;

    var confirmedIds = <String>[];
    if (walkovers.isNotEmpty) {
      List<bool>? userConfirmation = await requestDialogChoice<List<bool>>(
        reason: (
          preview.withdrawing
              ? StatusChangeDirection.withdrawal
              : StatusChangeDirection.reentering,
          walkovers,
        ),
      );

      if (userConfirmation == null) {
        return FormzSubmissionStatus.canceled;
      }

      assert(userConfirmation.length == walkovers.length);

      var confirmedCompetitions = walkovers.keys.whereIndexed(
        (index, _) => userConfirmation[index],
      );
      confirmedIds = confirmedCompetitions.map((c) => c.id).toList();
    }

    await statusEndpoint.post(
      pathParams: {
        "player": state.player.id,
      },
      body: {
        "status": statusIndex,
        "competitions": confirmedIds,
      },
    );

    return FormzSubmissionStatus.success;
  }

  void _onPlayerUpdated(CollectionUpdateEvent<Player> event) {
    if (event.model != state.player) {
      return;
    }

    emit(state.copyWith(player: event.model));
  }

  @override
  void onCollectionUpdate(List<List<Model>> collections,
      CollectionUpdateEvent<Model>? updateEvent) {}
}

enum StatusChangeDirection {
  withdrawal,
  reentering,
}
