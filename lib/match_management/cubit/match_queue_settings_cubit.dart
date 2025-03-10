import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';

part 'match_queue_settings_state.dart';

class MatchQueueSettingsCubit
    extends CollectionQuerierCubit<MatchQueueSettingsState> {
  MatchQueueSettingsCubit({
    required ModelStore<TournamentEvent> tournamentRepository,
  }) : super(
          modelStores: [
            tournamentRepository,
          ],
          MatchQueueSettingsState(),
        );

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    CollectionUpdateEvent<Model>? updateEvent,
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

    TournamentEvent tournamentWithUpdatedRestTime =
        state.tournament.copyWith(playerRestTime: newPlayerRestTime);

    TournamentEvent? updatedTournament =
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

    TournamentEvent tournamentWithUpdatedQueueMode =
        state.tournament.copyWith(queueMode: queueMode);

    TournamentEvent? updatedTournament =
        await querier.updateModel(tournamentWithUpdatedQueueMode);
    if (updatedTournament == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }
}
