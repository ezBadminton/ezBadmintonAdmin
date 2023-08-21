import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:formz/formz.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

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

    List<Court>? courtsOfGym = await _fetchCourtsOfGym();
    if (courtsOfGym == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    Court newCourt = Court.newCourt(
      name: _getCourtName(row, column, courtsOfGym),
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

    List<Court>? courtsOfGym = await _fetchCourtsOfGym();
    if (courtsOfGym == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

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
            name: _getCourtName(slot.row, slot.column, courtsOfGym),
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

  Future<List<Court>?> _fetchCourtsOfGym() async {
    List<Court>? courts = await querier.fetchCollection<Court>();
    if (courts == null) {
      return null;
    }

    List<Court> courtsOfGym =
        courts.where((c) => c.gymnasium == state.gymnasium).toList();

    return courtsOfGym;
  }

  String _getCourtName(int row, int column, List<Court> courtsOfGym) {
    String name = display_strings.courtName(state.gymnasium, row, column, l10n);

    List<String> otherNames = courtsOfGym.map((c) => c.name).toList();

    int suffix = 1;
    while (otherNames.contains(_numberSuffix(name, suffix))) {
      suffix += 1;
    }

    return _numberSuffix(name, suffix);
  }

  String _numberSuffix(String name, int suffix) {
    if (suffix == 1) {
      return name;
    } else {
      return '$name ($suffix)';
    }
  }

  void _onGymnasiumCollectionUpdate(CollectionUpdateEvent<Gymnasium> event) {
    if (event.updateType == UpdateType.update &&
        state.gymnasium == event.model) {
      emit(state.copyWith(gymnasium: event.model));
    }
  }
}
