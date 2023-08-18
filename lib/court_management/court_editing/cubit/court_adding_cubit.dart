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
