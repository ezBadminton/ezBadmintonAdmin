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

  _onGymnasiumCollectionUpdate(List<CollectionUpdateEvent<Gymnasium>> events) {
    List<CollectionUpdateEvent<Gymnasium>> updated =
        events.where((e) => state.containsKey(e.model)).toList();

    if (updated.isEmpty) {
      return;
    }

    Map<Gymnasium, GymnasiumCourtViewController> updatedControllers =
        Map.of(state);

    for (CollectionUpdateEvent<Gymnasium> event in events) {
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
    }

    emit(updatedControllers);
  }

  @override
  void onCollectionUpdate(List<List<Model>> collections,
      List<CollectionUpdateEvent<Model>> updateEvents) {}
}
