import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:formz/formz.dart';

part 'gymnasium_editing_state.dart';

class GymnasiumEditingCubit
    extends CollectionQuerierCubit<GymnasiumEditingState>
    with DialogCubit<GymnasiumEditingState> {
  GymnasiumEditingCubit({
    Gymnasium? gymnasium,
    required this.tournamentProgressGetter,
    required CollectionRepository<Gymnasium> gymnasiumRepository,
    required CollectionRepository<Court> courtRepository,
  }) : super(
          collectionRepositories: [
            gymnasiumRepository,
            courtRepository,
          ],
          GymnasiumEditingState(gymnasium: gymnasium),
        ) {
    if (gymnasium != null) {
      emit(state.copyWithGymnasium(gymnasium));
    }
  }

  final TournamentProgressState Function() tournamentProgressGetter;

  static const _maxCourtGridDimension = 15;

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

    FormzSubmissionStatus gridHandled = await _applyCourtGridChanges();
    if (gridHandled != FormzSubmissionStatus.success) {
      emit(state.copyWith(formStatus: gridHandled));
      return;
    }

    Gymnasium editedGym = _applyChanges();
    Gymnasium? updatedGym = await querier.updateOrCreateModel(editedGym);
    if (updatedGym == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
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

  /// Deletes courts if the court grid was reduced
  Future<FormzSubmissionStatus> _applyCourtGridChanges() async {
    if (state.rows.value >= state.gymnasium.rows &&
        state.columns.value >= state.gymnasium.columns) {
      return FormzSubmissionStatus.success;
    }

    List<Court> courts = querier.getCollection<Court>();

    List<Court> courtsOfGym =
        courts.where((c) => c.gymnasium == state.gymnasium).toList();

    Set<Court> courtsToDelete = courtsOfGym
        .where((c) =>
            c.positionX > state.columns.value - 1 ||
            c.positionY > state.rows.value - 1)
        .toSet();

    if (courtsToDelete.isEmpty) {
      return FormzSubmissionStatus.success;
    }

    TournamentProgressState progressState = tournamentProgressGetter();

    Set<Court> occupiedCourtsToDelete =
        progressState.occupiedCourts.keys.toSet().intersection(courtsToDelete);

    if (occupiedCourtsToDelete.isNotEmpty) {
      requestDialogChoice<Error>();
      return FormzSubmissionStatus.failure;
    }

    bool userConfirmation = (await requestDialogChoice<bool>())!;
    if (!userConfirmation) {
      return FormzSubmissionStatus.canceled;
    }

    Iterable<Future<bool>> courtDeletions =
        courtsToDelete.map((c) => querier.deleteModel(c));
    List<bool> courtsDeleted = await Future.wait(courtDeletions);
    if (courtsDeleted.contains(false)) {
      return FormzSubmissionStatus.failure;
    }

    return FormzSubmissionStatus.success;
  }

  Gymnasium _applyChanges() {
    return state.gymnasium.copyWith(
      name: state.name.value,
      directions: state.directions.value,
      rows: state.rows.value,
      columns: state.columns.value,
    );
  }

  @override
  void onCollectionUpdate(List<List<Model>> collections,
      List<CollectionUpdateEvent<Model>> updateEvents) {}
}
