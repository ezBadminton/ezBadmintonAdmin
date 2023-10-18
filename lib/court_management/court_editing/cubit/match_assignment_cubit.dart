import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:formz/formz.dart';

part 'match_assignment_state.dart';

class MatchAssignmentCubit
    extends CollectionQuerierCubit<MatchAssignmentState> {
  MatchAssignmentCubit({
    required Court court,
    required CollectionRepository<MatchData> matchDataRepository,
    required CollectionRepository<Court> courtRepository,
  }) : super(
          collectionRepositories: [
            matchDataRepository,
            courtRepository,
          ],
          MatchAssignmentState(court: court),
        ) {
    subscribeToCollectionUpdates(
      courtRepository,
      _onCourtCollectionUpdate,
    );
  }

  void assignMatch(MatchData matchData) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    MatchData matchWithCourt = matchData.copyWith(court: state.court);

    MatchData? updatedMatch = await querier.updateModel(matchWithCourt);
    if (updatedMatch == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  void _onCourtCollectionUpdate(CollectionUpdateEvent<Court> event) {
    if (event.updateType == UpdateType.update && event.model == state.court) {
      emit(state.copyWith(court: event.model));
    }
  }
}
