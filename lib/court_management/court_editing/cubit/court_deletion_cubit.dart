import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:formz/formz.dart';

part 'court_deletion_state.dart';

class CourtDeletionCubit extends CollectionQuerierCubit<CourtDeletionState> {
  CourtDeletionCubit({
    required Court court,
    required CollectionRepository<Court> courtRepository,
  }) : super(
          collectionRepositories: [courtRepository],
          CourtDeletionState(court: court),
        );

  void courtDeleted() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    bool courtDeleted = await querier.deleteModel(state.court);
    if (!courtDeleted) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }
}
