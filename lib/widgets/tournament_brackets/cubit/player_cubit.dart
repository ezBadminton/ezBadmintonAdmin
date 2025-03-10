import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
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
    CollectionUpdateEvent<Model>? updateEvent,
  ) {
    bool doUpdate = updateEvent != null &&
        (updateEvent.model == state.player ||
            updateEvent.model == state.player.club);
    if (!doUpdate) {
      return;
    }

    switch (updateEvent.model) {
      case Player p:
        emit(PlayerState(p));
      case Club _:
        emit(PlayerState(state.player));
    }
  }
}
