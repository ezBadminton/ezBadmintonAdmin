import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';

part 'match_queue_settings_state.dart';

class MatchQueueSettingsCubit
    extends CollectionQuerierCubit<MatchQueueSettingsState> {
  MatchQueueSettingsCubit({
    required CollectionRepository<Tournament> tournamentRepository,
  }) : super(
          collectionRepositories: [
            tournamentRepository,
          ],
          MatchQueueSettingsState(),
        );

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    List<CollectionUpdateEvent<Model>> updateEvents,
  ) {
    MatchQueueSettingsState updatedState = state.copyWith(
      collections: collections,
      loadingStatus: LoadingStatus.done,
    );

    emit(updatedState);
  }

  void playerRestTimeChanged(String playerRestTime) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    int newPlayerRestTime = int.tryParse(playerRestTime) ?? 0;

    Tournament tournamentWithUpdatedRestTime =
        state.tournament.copyWith(playerRestTime: newPlayerRestTime);

    Tournament? updatedTournament =
        await querier.updateModel(tournamentWithUpdatedRestTime);
    if (updatedTournament == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  void queueModeChanged(QueueMode queueMode) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    Tournament tournamentWithUpdatedQueueMode =
        state.tournament.copyWith(queueMode: queueMode);

    Tournament? updatedTournament =
        await querier.updateModel(tournamentWithUpdatedQueueMode);
    if (updatedTournament == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }
}
