import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:formz/formz.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

part 'court_adding_state.dart';

class CourtAddingCubit extends CollectionQuerierCubit<CourtAddingState> {
  CourtAddingCubit({
    required Gymnasium gymnasium,
    required CollectionRepository<Court> courtRepository,
    required CollectionRepository<Gymnasium> gymnasiumRepository,
    required this.l10n,
  }) : super(
          collectionRepositories: [
            courtRepository,
            gymnasiumRepository,
          ],
          CourtAddingState(gymnasium: gymnasium),
        ) {
    subscribeToCollectionUpdates(
      gymnasiumRepository,
      _onGymnasiumCollectionUpdate,
    );
  }

  final AppLocalizations l10n;

  void courtAdded(int row, int column) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    Court newCourt = Court.newCourt(
      name: l10n.courtN(column + row * state.gymnasium.columns + 1),
      gymnasium: state.gymnasium,
      x: column,
      y: row,
    );

    Court? createdCourt = await querier.createModel(newCourt);
    if (createdCourt == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  void addAllMissingCourts() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    List<Court>? courts = await querier.fetchCollection<Court>();
    if (courts == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    List<Court> courtsOfGym =
        courts.where((c) => c.gymnasium == state.gymnasium).toList();

    List<({int row, int column})> freeCourtSlots = [
      for (int row = 0; row < state.gymnasium.rows; row += 1)
        for (int column = 0; column < state.gymnasium.columns; column += 1)
          (row: row, column: column),
    ]
        .where(
          (slot) =>
              courtsOfGym.firstWhereOrNull((court) =>
                  court.positionX == slot.column &&
                  court.positionY == slot.row) ==
              null,
        )
        .toList();

    List<Court> newCourts = freeCourtSlots
        .map(
          (slot) => Court.newCourt(
            name: l10n
                .courtN(slot.column + slot.row * state.gymnasium.columns + 1),
            gymnasium: state.gymnasium,
            x: slot.column,
            y: slot.row,
          ),
        )
        .toList();

    Iterable<Future<Court?>> courtCreations =
        newCourts.map((c) => querier.createModel(c));

    List<Court?> createdCourts = await Future.wait(courtCreations);
    if (createdCourts.contains(null)) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  void _onGymnasiumCollectionUpdate(CollectionUpdateEvent<Gymnasium> event) {
    if (event.updateType == UpdateType.update &&
        state.gymnasium == event.model) {
      emit(state.copyWith(gymnasium: event.model));
    }
  }
}
