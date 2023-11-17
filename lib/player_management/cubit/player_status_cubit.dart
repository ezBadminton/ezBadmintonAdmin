import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:formz/formz.dart';

part 'player_status_state.dart';

class PlayerStatusCubit extends CollectionQuerierCubit<PlayerStatusState>
    with DialogCubit {
  PlayerStatusCubit({
    required Player player,
    required this.tournamentProgressGetter,
    required CollectionRepository<Player> playerRepository,
    required CollectionRepository<MatchData> matchDataRepository,
  }) : super(
          PlayerStatusState(player: player),
          collectionRepositories: [
            playerRepository,
            matchDataRepository,
          ],
        ) {
    subscribeToCollectionUpdates(playerRepository, _onPlayerUpdated);
  }

  final TournamentProgressState Function() tournamentProgressGetter;

  void statusChanged(PlayerStatus status) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    PlayerStatus previousStatus = state.player.status;
    FormzSubmissionStatus withdrawalStatus =
        await _handlePlayerWithdrawal(previousStatus, status);

    if (withdrawalStatus != FormzSubmissionStatus.success) {
      emit(state.copyWith(formStatus: withdrawalStatus));
      return;
    }

    var playerWithStatus = state.player.copyWith(status: status);
    var updatedPlayer = await querier.updateModel(playerWithStatus);

    if (updatedPlayer == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  Future<FormzSubmissionStatus> _handlePlayerWithdrawal(
    PlayerStatus previous,
    PlayerStatus current,
  ) async {
    bool isWithdrawal =
        previous == PlayerStatus.attending && current != PlayerStatus.attending;

    if (!isWithdrawal) {
      return FormzSubmissionStatus.success;
    }

    TournamentProgressState progressState = tournamentProgressGetter();

    List<BadmintonTournamentMode> runningTournaments = progressState
        .runningTournaments.values
        .where((t) => !t.isCompleted())
        .toList();

    Map<BadmintonTournamentMode, Team> teamsOfPlayer = {};
    for (BadmintonTournamentMode tournament in runningTournaments) {
      Team? teamOfPlayer = tournament.entries
          .rank()
          .map((participant) => participant.resolvePlayer())
          .firstWhereOrNull((team) => team!.players.contains(state.player));

      if (teamOfPlayer != null) {
        teamsOfPlayer.putIfAbsent(tournament, () => teamOfPlayer);
      }
    }

    List<BadmintonMatch> walkoverMatches = teamsOfPlayer.entries
        .expand((entry) => entry.key.withdrawPlayer(entry.value))
        .where((match) => match.matchData!.status == MatchStatus.normal)
        .toList();

    if (walkoverMatches.isNotEmpty) {
      bool userConfirmation =
          (await requestDialogChoice<bool>(reason: walkoverMatches))!;

      if (!userConfirmation) {
        return FormzSubmissionStatus.canceled;
      }
    }

    List<MatchData> matchDataWithNewStatus = walkoverMatches.map(
      (match) {
        MatchStatus newMatchStatus;
        if (match.a.resolvePlayer()!.players.contains(state.player)) {
          newMatchStatus = MatchStatus.walkover2;
        } else {
          newMatchStatus = MatchStatus.walkover1;
        }

        MatchData newMatchData = match.matchData!;

        newMatchData = newMatchData.copyWith(status: newMatchStatus);

        if (newMatchData.court != null && newMatchData.endTime == null) {
          // If the match is already running, cancel it
          newMatchData = newMatchData.copyWith(
            startTime: null,
            court: null,
            courtAssignmentTime: null,
          );
        }

        return newMatchData;
      },
    ).toList();

    List<MatchData?> updatedMatchData =
        await querier.updateModels(matchDataWithNewStatus);

    if (updatedMatchData.contains(null)) {
      return FormzSubmissionStatus.failure;
    }

    return FormzSubmissionStatus.success;
  }

  void _onPlayerUpdated(CollectionUpdateEvent<Player> event) {
    if (event.model == state.player) {
      emit(state.copyWith(player: event.model));
    }
  }
}
