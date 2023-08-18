import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

part 'gymnasium_selection_state.dart';

class GymnasiumSelectionCubit
    extends CollectionFetcherCubit<GymnasiumSelectionState> {
  GymnasiumSelectionCubit({
    required CollectionRepository<Gymnasium> gymnasiumRepository,
    required CollectionRepository<Court> courtRepository,
  }) : super(
          collectionRepositories: [
            gymnasiumRepository,
            courtRepository,
          ],
          GymnasiumSelectionState(),
        ) {
    loadCollections();
    subscribeToCollectionUpdates(
      gymnasiumRepository,
      _onGymnasiumCollectionUpdate,
    );
    subscribeToCollectionUpdates(courtRepository, (_) => loadCollections());
  }

  void loadCollections() {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    fetchCollectionsAndUpdateState(
      [
        collectionFetcher<Court>(),
      ],
      onSuccess: (updatedState) {
        List<Court> courtCollection = updatedState.getCollection<Court>();
        List<Court> courtsOfGym = _getCourtsOfGym(
          courtCollection,
          state.gymnasium.value,
        );

        emit(updatedState.copyWith(
          courtsOfGym: courtsOfGym,
          loadingStatus: LoadingStatus.done,
        ));
      },
      onFailure: () {
        emit(state.copyWith(loadingStatus: LoadingStatus.failed));
      },
    );
  }

  void gymnasiumToggled(Gymnasium gymnasium) {
    if (state.gymnasium.value == gymnasium) {
      _unselectGymnasium();
    } else {
      _selectGymnasium(gymnasium);
    }
  }

  void _selectGymnasium(Gymnasium gymnasium) {
    List<Court> courtsOfGym = _getCourtsOfGym(
      state.getCollection<Court>(),
      gymnasium,
    );
    emit(state.copyWith(
      gymnasium: SelectionInput.pure(
        emptyAllowed: true,
        value: gymnasium,
      ),
      courtsOfGym: courtsOfGym,
    ));
  }

  void _unselectGymnasium() {
    emit(state.copyWith(
      gymnasium: const SelectionInput.pure(
        emptyAllowed: true,
        value: null,
      ),
      courtsOfGym: [],
    ));
  }

  static List<Court> _getCourtsOfGym(
    List<Court> courtCollection,
    Gymnasium? gymnasium,
  ) {
    List<Court> courtsOfGym =
        courtCollection.where((c) => c.gymnasium == gymnasium).toList();
    return courtsOfGym;
  }

  void _onGymnasiumCollectionUpdate(CollectionUpdateEvent<Gymnasium> event) {
    Gymnasium updatedGymnasium = event.model;

    switch (event.updateType) {
      case UpdateType.create:
        _selectGymnasium(updatedGymnasium);
        break;
      case UpdateType.update:
        if (updatedGymnasium == state.gymnasium.value) {
          _selectGymnasium(updatedGymnasium);
        }
        break;
      case UpdateType.delete:
        if (updatedGymnasium == state.gymnasium.value) {
          _unselectGymnasium();
        }
        break;
    }
  }
}
