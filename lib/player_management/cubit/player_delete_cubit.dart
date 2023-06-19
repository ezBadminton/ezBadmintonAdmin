import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_delete_state.dart';
import 'package:ez_badminton_admin_app/player_management/models/competition_registration.dart';
import 'package:ez_badminton_admin_app/player_management/utils/competition_registration.dart';
import 'package:formz/formz.dart';

class PlayerDeleteCubit extends CollectionQuerierCubit<PlayerDeleteState> {
  PlayerDeleteCubit({
    required Player player,
    required CollectionRepository<Player> playerRepository,
    required CollectionRepository<Competition> competitionRepository,
    required CollectionRepository<Team> teamRepository,
  }) : super(
          collectionRepositories: [
            playerRepository,
            competitionRepository,
            teamRepository,
          ],
          PlayerDeleteState(player: player),
        );

  void confirmDialogOpened() {
    emit(state.copyWith(showConfirmDialog: true));
  }

  void confirmChoiceMade(bool confirmed) {
    emit(state.copyWith(showConfirmDialog: false));
    if (confirmed) {
      _deletePlayer();
    }
  }

  void _deletePlayer() async {
    if (state.formStatus != FormzSubmissionStatus.inProgress) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));
    }
    List<Competition>? competitions =
        await querier.fetchCollection<Competition>();

    if (competitions == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    Player player = state.player;
    Iterable<CompetitionRegistration> registrations = registrationsOfPlayer(
      player,
      competitions,
    );

    for (CompetitionRegistration registration in registrations) {
      Competition? updatedCompetition =
          await deregisterCompetition(registration, querier);

      if (updatedCompetition == null) {
        emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
        return;
      }
    }

    bool deletionSuccessful = await querier.deleteModel(player);
    if (!deletionSuccessful) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }
}
