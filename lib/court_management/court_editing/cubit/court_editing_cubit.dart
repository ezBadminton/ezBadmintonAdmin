import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';

part 'court_editing_state.dart';

class CourtEditingCubit extends CollectionFetcherCubit<CourtEditingState> {
  CourtEditingCubit({
    required CollectionRepository<Court> courtRepository,
    required CollectionRepository<Gymnasium> gymnasiumRepository,
  }) : super(
          collectionRepositories: [
            courtRepository,
            gymnasiumRepository,
          ],
          CourtEditingState(),
        ) {
    subscribeToCollectionUpdates(
      gymnasiumRepository,
      _onGymnasiumCollectionUpdate,
    );
  }

  void loadCollections() {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    fetchCollectionsAndUpdateState(
      [
        collectionFetcher<Court>(),
        collectionFetcher<Gymnasium>(),
      ],
      onSuccess: (updatedState) {
        emit(updatedState.copyWith(loadingStatus: LoadingStatus.done));
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
    emit(state.copyWith(
      gymnasium: SelectionInput.pure(
        emptyAllowed: true,
        value: gymnasium,
      ),
    ));
  }

  void _unselectGymnasium() {
    emit(state.copyWith(
      gymnasium: const SelectionInput.pure(
        emptyAllowed: true,
        value: null,
      ),
    ));
  }

  void _onGymnasiumCollectionUpdate(CollectionUpdateEvent<Gymnasium> event) {
    Gymnasium updatedGymnasium = event.model;
    if (state.gymnasium.value != updatedGymnasium) {
      return;
    }

    switch (event.updateType) {
      case UpdateType.update:
        _selectGymnasium(updatedGymnasium);
        break;
      case UpdateType.delete:
        _unselectGymnasium();
        break;
      default:
        break;
    }
  }
}
