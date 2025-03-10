import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/utils/gymnasium_court_view_controller.dart';

class GymnasiumCourtViewCubit extends CollectionQuerierCubit<
    Map<Gymnasium, GymnasiumCourtViewController>> {
  GymnasiumCourtViewCubit({
    required ModelStore<Gymnasium> gymnasiumRepository,
  }) : super(
          modelStores: [gymnasiumRepository],
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

    Map<Gymnasium, GymnasiumCourtViewController> updatedControllers =
        Map.of(state);

    GymnasiumCourtViewController controller = state[event.model]!;

    switch (event.updateType) {
      case UpdateType.update:
        controller.gymnasium = event.model;
        break;
      case UpdateType.delete:
        controller.dispose();
        updatedControllers.remove(event.model);
        break;
      default:
        break;
    }

    emit(updatedControllers);
  }

  @override
  void onCollectionUpdate(List<List<Model>> collections,
      CollectionUpdateEvent<Model>? updateEvent) {}
}
