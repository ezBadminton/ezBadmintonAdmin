import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/utils/gymnasium_court_view_controller.dart';

class GymnasiumCourtViewCubit extends CollectionQuerierCubit<
    Map<Gymnasium, GymnasiumCourtViewController>> {
  GymnasiumCourtViewCubit({
    required CollectionRepository<Gymnasium> gymnasiumRepository,
  }) : super(
          collectionRepositories: [gymnasiumRepository],
          const {},
        ) {
    subscribeToCollectionUpdates(
      gymnasiumRepository,
      _onGymnasiumCollectionUpdate,
    );
  }

  GymnasiumCourtViewController getViewController(Gymnasium gymnasium) {
    if (state.containsKey(gymnasium)) {
      return state[gymnasium]!;
    } else {
      GymnasiumCourtViewController newController =
          GymnasiumCourtViewController(gymnasium: gymnasium);
      var newState = Map.of(state)..putIfAbsent(gymnasium, () => newController);
      emit(newState);
      return newController;
    }
  }

  _onGymnasiumCollectionUpdate(CollectionUpdateEvent<Gymnasium> event) {
    if (!state.containsKey(event.model)) {
      return;
    }

    GymnasiumCourtViewController controller = state[event.model]!;

    switch (event.updateType) {
      case UpdateType.update:
        controller.gymnasium = event.model;
        break;
      case UpdateType.delete:
        var newState = Map.of(state)..remove(event.model);
        emit(newState);
        break;
      default:
        break;
    }
  }
}
