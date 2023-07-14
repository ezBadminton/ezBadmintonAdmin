import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_status_state.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

class PlayerStatusCubit extends CollectionQuerierCubit<PlayerStatusState> {
  PlayerStatusCubit({
    required Player player,
    required CollectionRepository<Player> playerRepository,
  }) : super(
          PlayerStatusState(player: player),
          collectionRepositories: [playerRepository],
        ) {
    subscribeToCollectionUpdates(playerRepository, _onPlayerUpdated);
  }

  void statusChanged(PlayerStatus status) async {
    emit(state.copyWith(loadingStatus: LoadingStatus.loading));

    var playerWithStatus = state.player.copyWith(status: status);
    var updatedPlayer = await querier.updateModel(playerWithStatus);

    if (updatedPlayer == null) {
      emit(state.copyWith(loadingStatus: LoadingStatus.failed));
    } else {
      emit(state.copyWith(loadingStatus: LoadingStatus.done));
    }
  }

  void _onPlayerUpdated(CollectionUpdateEvent event) {
    if (event.model == state.player) {
      emit(state.copyWith(player: event.model as Player));
    }
  }
}
