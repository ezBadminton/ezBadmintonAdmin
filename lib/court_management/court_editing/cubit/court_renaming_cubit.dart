import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:formz/formz.dart';

part 'court_renaming_state.dart';

class CourtRenamingCubit extends CollectionQuerierCubit<CourtRenamingState> {
  CourtRenamingCubit({
    required Court court,
    required CollectionRepository<Court> courtRepository,
  }) : super(
          collectionRepositories: [
            courtRepository,
          ],
          CourtRenamingState(court: court),
        ) {
    subscribeToCollectionUpdates(
      courtRepository,
      _onCourtCollectionUpdate,
    );
  }

  void formOpened() {
    emit(state.copyWith(
      isFormOpen: true,
      name: NonEmptyInput.pure(state.court.name),
    ));
  }

  void nameChanged(String name) {
    emit(state.copyWith(name: NonEmptyInput.dirty(name)));
  }

  void formSubmitted() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    if (state.name.isPure || state.name.isNotValid) {
      emit(state.copyWith(isFormOpen: false));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    List<Court>? courts = await querier.fetchCollection<Court>();
    if (courts == null) {
      emit(state.copyWith(
        formStatus: FormzSubmissionStatus.failure,
        isFormOpen: false,
      ));
      return;
    }

    // Don't allow duplicate names in the same gym
    List<String> otherNames = courts
        .where((c) => c != state.court && c.gymnasium == state.court.gymnasium)
        .map((c) => c.name.toLowerCase())
        .toList();

    String newName = state.name.value;

    if (otherNames.contains(newName.toLowerCase())) {
      emit(state.copyWith(
        formStatus: FormzSubmissionStatus.initial,
        isFormOpen: false,
      ));
      return;
    }

    Court renamedCourt = state.court.copyWith(name: newName);
    Court? updatedCourt = await querier.updateModel(renamedCourt);
    if (updatedCourt == null) {
      emit(state.copyWith(
        formStatus: FormzSubmissionStatus.failure,
        isFormOpen: false,
      ));
      return;
    }

    emit(state.copyWith(
      formStatus: FormzSubmissionStatus.success,
      isFormOpen: false,
    ));
  }

  void _onCourtCollectionUpdate(CollectionUpdateEvent<Court> event) {
    if (event.updateType == UpdateType.update && event.model == state.court) {
      emit(state.copyWith(court: event.model));
    }
  }
}
