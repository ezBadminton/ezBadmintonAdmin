import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/utils/list_extension/list_extension.dart';
import 'package:model_repository/model_repository.dart';

part 'player_state.dart';

class PlayerCubit extends CollectionQuerierCubit<PlayerState> {
  PlayerCubit({
    required Player player,
    required ModelStore<Player> playerStore,
    required ModelStore<Club> clubStore,
  }) : super(
          modelStores: [
            playerStore,
            clubStore,
          ],
          PlayerState(player),
        );

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    List<CollectionUpdateEvent<Model>>? updateEvents,
  ) {
    if (updateEvents == null) {
      return;
    }
    Player? updatedPlayer = updateEvents.latestVersion(state.player);
    Club? updatedClub = updateEvents.latestVersion(state.player.club);
    if (updatedPlayer != null || updatedClub != null) {
      emit(PlayerState(updatedPlayer ?? state.player));
    }
  }
}
