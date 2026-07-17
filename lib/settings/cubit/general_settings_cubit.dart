import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';

part 'general_settings_state.dart';

class GeneralSettingsCubit extends CollectionQuerierCubit<GeneralSettingsState> {
  GeneralSettingsCubit({
    required ModelStore<TournamentEvent> tournamentRepository,
  }) : super(
          modelStores: [
            tournamentRepository,
          ],
          GeneralSettingsState(),
        );

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    CollectionUpdateEvent<Model>? updateEvent,
  ) {
    GeneralSettingsState updatedState = state.copyWith(
      collections: collections,
      loadingStatus: LoadingStatus.done,
    );

    emit(updatedState);
  }

  void tournamentTitleChanged(String title) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    TournamentEvent tournamentWithUpdatedTitle =
        state.tournament.copyWith(title: title);

    TournamentEvent? updatedTournament =
        await querier.updateModel(tournamentWithUpdatedTitle);
    if (updatedTournament == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }
}
