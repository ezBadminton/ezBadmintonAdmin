import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_delete_state.dart';
import 'package:ez_badminton_admin_app/player_management/models/competition_registration.dart';
import 'package:ez_badminton_admin_app/player_management/utils/competition_registration.dart';
import 'package:ez_badminton_admin_app/widgets/confirm_dialog/cubit_mixin/dialog_cubit.dart';
import 'package:formz/formz.dart';

class PlayerDeleteCubit extends CollectionQuerierCubit<PlayerDeleteState>
    with DialogCubit<PlayerDeleteState> {
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

  void playerDeleted() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    bool deletionConfirmed = (await requestDialogChoice<bool>())!;
    if (!deletionConfirmed) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.canceled));
      return;
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
