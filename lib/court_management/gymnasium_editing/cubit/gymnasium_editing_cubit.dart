import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';

part 'gymnasium_editing_state.dart';

class GymnasiumEditingCubit
    extends CollectionFetcherCubit<GymnasiumEditingState> {
  GymnasiumEditingCubit({
    Gymnasium? gymnasium,
    required CollectionRepository<Gymnasium> gymnasiumRepository,
  }) : super(
          collectionRepositories: [
            gymnasiumRepository,
          ],
          GymnasiumEditingState(gymnasium: gymnasium),
        ) {
    loadCollections();
  }

  static const _maxCourtGridDimension = 15;

  void loadCollections() {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    fetchCollectionsAndUpdateState(
      [
        collectionFetcher<Gymnasium>(),
      ],
      onSuccess: (updatedState) {
        if (state.gymnasium.id.isNotEmpty && state.isPure) {
          updatedState = updatedState.copyWithGymnasium(state.gymnasium);
        }
        emit(updatedState.copyWith(loadingStatus: LoadingStatus.done));
      },
      onFailure: () {
        emit(state.copyWith(loadingStatus: LoadingStatus.failed));
      },
    );
  }

  void formSubmitted() async {
    if (!state.isValid) {
      var newState = state.copyWith(formStatus: FormzSubmissionStatus.failure);
      emit(newState);
      return;
    }

    var progressState = state.copyWith(
      formStatus: FormzSubmissionStatus.inProgress,
    );
    emit(progressState);

    Gymnasium editedGym = _applyChanges();
    Gymnasium? updatedGym = await querier.updateOrCreateModel(editedGym);
    if (updatedGym == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
    }

    emit(state.copyWith(
      gymnasium: updatedGym,
      formStatus: FormzSubmissionStatus.success,
    ));
  }

  void nameChanged(String name) {
    emit(state.copyWith(name: NonEmptyInput.dirty(name)));
  }

  void directionsChanged(String directions) {
    emit(state.copyWith(directions: NoValidationInput.dirty(directions)));
  }

  void rowsChanged(int rows) {
    if (rows > 0 && rows <= _maxCourtGridDimension) {
      emit(state.copyWith(rows: PositiveNonzeroNumber.dirty(rows)));
    }
  }

  void columnsChanged(int columns) {
    if (columns > 0 && columns <= _maxCourtGridDimension) {
      emit(state.copyWith(columns: PositiveNonzeroNumber.dirty(columns)));
    }
  }

  Gymnasium _applyChanges() {
    return state.gymnasium.copyWith(
      name: state.name.value,
      directions: state.directions.value,
      rows: state.rows.value,
      columns: state.columns.value,
    );
  }
}
