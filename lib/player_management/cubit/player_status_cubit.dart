import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/player_management/models/competition_registration.dart';
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
    FormzSubmissionStatus participationStatus =
        await _handlePlayerTournamentParticipation(previousStatus, status);

    if (participationStatus != FormzSubmissionStatus.success) {
      emit(state.copyWith(formStatus: participationStatus));
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

  /// When the player withdraws from the tournament (e.g. forfeit or injury) or
  /// the withdrawal is reverted, this method handles the walkovers in the
  /// competitions that the player participates in.
  Future<FormzSubmissionStatus> _handlePlayerTournamentParticipation(
    PlayerStatus previous,
    PlayerStatus current,
  ) async {
    bool isWithdrawal =
        previous == PlayerStatus.attending && current != PlayerStatus.attending;

    bool isReentering =
        previous != PlayerStatus.attending && current == PlayerStatus.attending;

    if (isWithdrawal) {
      return _handlePlayerWithdrawal();
    }

    if (isReentering) {
      return _handlePlayerReentering();
    }

    return FormzSubmissionStatus.success;
  }

  Future<FormzSubmissionStatus> _handlePlayerWithdrawal() async {
    Map<CompetitionRegistration, BadmintonTournamentMode> tournamentsOfPlayer =
        _getTournamentsOfPlayer();

    // The walkovers in each registered tournament
    Map<CompetitionRegistration, List<BadmintonMatch>> walkovers =
        tournamentsOfPlayer.map(
      (registration, tournament) => MapEntry(
        registration,
        tournament
            .withdrawPlayer(registration.team)
            .whereNot(
              (match) =>
                  match.matchData!.withdrawnTeams.contains(registration.team),
            )
            .toList(),
      ),
    );

    if (walkovers.values.expand((matches) => matches).isEmpty) {
      return FormzSubmissionStatus.success;
    }

    List<bool>? userConfirmation = await requestDialogChoice<List<bool>>(
      reason: (
        StatusChangeDirection.withdrawal,
        walkovers,
        walkovers.keys.toList(),
      ),
    );

    if (userConfirmation == null) {
      return FormzSubmissionStatus.canceled;
    }

    assert(userConfirmation.length == walkovers.length);

    if (!userConfirmation.contains(true)) {
      return FormzSubmissionStatus.success;
    }

    walkovers = Map.fromEntries(
      walkovers.entries.whereIndexed((index, _) => userConfirmation[index]),
    );

    MatchData withdrawTeamFromMatch(Team team, MatchData matchData) {
      assert(!matchData.withdrawnTeams.contains(team));

      List<Team> newWithdrawnTeams = List.of(matchData.withdrawnTeams)
        ..add(team);

      MatchData newMatchData =
          matchData.copyWith(withdrawnTeams: newWithdrawnTeams);

      newMatchData = _cancelRunningMatch(newMatchData);

      return newMatchData;
    }

    List<MatchData> matchDataWithNewStatus = walkovers.entries
        .expand(
          (MapEntry<CompetitionRegistration, List<BadmintonMatch>> entry) =>
              entry.value.map(
            (match) => withdrawTeamFromMatch(entry.key.team, match.matchData!),
          ),
        )
        .toList();

    List<MatchData?> updatedMatchData =
        await querier.updateModels(matchDataWithNewStatus);

    if (updatedMatchData.contains(null)) {
      return FormzSubmissionStatus.failure;
    }

    return FormzSubmissionStatus.success;
  }

  Future<FormzSubmissionStatus> _handlePlayerReentering() async {
    Map<CompetitionRegistration, BadmintonTournamentMode> tournamentsOfPlayer =
        _getTournamentsOfPlayer();

    Map<CompetitionRegistration, List<BadmintonMatch>> currentWalkovers =
        Map.fromEntries(
      tournamentsOfPlayer.entries.map(
        (MapEntry<CompetitionRegistration, BadmintonTournamentMode> entry) {
          return MapEntry(
            entry.key,
            entry.value.matches
                .where((m) => !m.isDrawnBye)
                .where(
                  (m) => m.matchData!.withdrawnTeams.contains(entry.key.team),
                )
                .toList(),
          );
        },
      ).where((entry) => entry.value.isNotEmpty),
    );

    if (currentWalkovers.values.expand((matches) => matches).isEmpty) {
      return FormzSubmissionStatus.success;
    }

    Map<CompetitionRegistration, List<BadmintonMatch>> reenteredMatches =
        Map.fromEntries(
      tournamentsOfPlayer.entries.map(
        (MapEntry<CompetitionRegistration, BadmintonTournamentMode> entry) {
          return MapEntry(
            entry.key,
            entry.value.reenterPlayer(entry.key.team).toList(),
          );
        },
      ).where((entry) => entry.value.isNotEmpty),
    );

    List<bool>? userConfirmation = await requestDialogChoice<List<bool>>(
      reason: (
        StatusChangeDirection.reentering,
        currentWalkovers,
        reenteredMatches.keys.toList(),
      ),
    );

    if (userConfirmation == null) {
      return FormzSubmissionStatus.canceled;
    }

    assert(userConfirmation.length == reenteredMatches.length);

    if (!userConfirmation.contains(true)) {
      return FormzSubmissionStatus.success;
    }

    reenteredMatches = Map.fromEntries(reenteredMatches.entries.whereIndexed(
      (index, _) => userConfirmation[index],
    ));

    tournamentsOfPlayer = Map.fromEntries(tournamentsOfPlayer.entries.where(
      (entry) => reenteredMatches.keys.contains(entry.key),
    ));

    // Cancel matches that have are planned because those might not be
    // playable anymore after the player reentered when former walkovers become
    // normal matches again.
    List<MatchData> canceledMatches = tournamentsOfPlayer.values
        .expand((tournament) => tournament.matches)
        .where((m) => m.court != null && m.startTime == null)
        .map((match) => match.matchData!.copyWith(
              startTime: null,
              court: null,
              courtAssignmentTime: null,
            ))
        .toList();

    MatchData reenterTeamIntoMatch(Team team, MatchData matchData) {
      assert(matchData.withdrawnTeams.contains(team));

      List<Team> newWithdrawnTeams = List.of(matchData.withdrawnTeams)
        ..remove(team);

      MatchData newMatchData =
          matchData.copyWith(withdrawnTeams: newWithdrawnTeams);

      newMatchData = _cancelRunningMatch(newMatchData);

      return newMatchData;
    }

    List<MatchData> matchDataWithNewStatus = reenteredMatches.entries
        .expand(
          (MapEntry<CompetitionRegistration, List<BadmintonMatch>> entry) =>
              entry.value.map(
            (match) => reenterTeamIntoMatch(entry.key.team, match.matchData!),
          ),
        )
        .toList();

    List<MatchData?> updatedMatchData = await querier.updateModels([
      ...matchDataWithNewStatus,
      ...canceledMatches,
    ]);

    if (updatedMatchData.contains(null)) {
      return FormzSubmissionStatus.failure;
    }

    return FormzSubmissionStatus.success;
  }

  MatchData _cancelRunningMatch(MatchData matchData) {
    if (matchData.court != null && matchData.endTime == null) {
      // If the match is running, cancel it
      return matchData.copyWith(
        startTime: null,
        court: null,
        courtAssignmentTime: null,
      );
    }

    return matchData;
  }

  Map<CompetitionRegistration, BadmintonTournamentMode>
      _getTournamentsOfPlayer() {
    TournamentProgressState progressState = tournamentProgressGetter();

    List<BadmintonTournamentMode> runningTournaments =
        progressState.runningTournaments.values.toList();

    Map<CompetitionRegistration, BadmintonTournamentMode> tournamentsOfPlayer =
        {};
    for (BadmintonTournamentMode tournament in runningTournaments) {
      CompetitionRegistration? registration;
      try {
        registration = CompetitionRegistration.fromCompetition(
          player: state.player,
          competition: tournament.competition,
        );
      } catch (_) {
        // Player is not in this tournament
      }

      if (registration != null) {
        tournamentsOfPlayer.putIfAbsent(
          CompetitionRegistration.fromCompetition(
            player: state.player,
            competition: tournament.competition,
          ),
          () => tournament,
        );
      }
    }

    return tournamentsOfPlayer;
  }

  void _onPlayerUpdated(CollectionUpdateEvent<Player> event) {
    if (event.model == state.player) {
      emit(state.copyWith(player: event.model));
    }
  }
}

enum StatusChangeDirection {
  withdrawal,
  reentering,
}
