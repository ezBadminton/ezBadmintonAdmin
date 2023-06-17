import 'dart:async';

import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_delete_state.dart';
import 'package:ez_badminton_admin_app/player_management/models/competition_registration.dart';
import 'package:ez_badminton_admin_app/player_management/utils/competition_registration.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';

class PlayerDeleteCubit extends CollectionFetcherCubit<PlayerDeleteState> {
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
        ) {
    _competitionUpdateSubscription = competitionRepository.updateStream.listen(
      _onCompetitionCollectionUpdate,
    );
    // Since collections are cached we take out a copy of the Team collection
    // now instead of doing it on delete
    loadCompetitions();
  }

  late final StreamSubscription _competitionUpdateSubscription;

  void loadCompetitions() {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    fetchCollectionsAndUpdateState(
      [collectionFetcher<Competition>()],
      onSuccess: (updatedState) {
        emit(updatedState.copyWith(loadingStatus: LoadingStatus.done));
      },
      onFailure: () {
        emit(state.copyWith(loadingStatus: LoadingStatus.failed));
      },
    );
  }

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
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    Player player = state.player;
    Iterable<CompetitionRegistration> registrations = registrationsOfPlayer(
      player,
      state.getCollection<Competition>(),
    );

    for (CompetitionRegistration registration in registrations) {
      Team team = registration.team;
      Competition competition = registration.competition;
      List<Team> updatedCompetitionRegistrations =
          List.of(competition.registrations)..remove(team);

      if (team.players.length == 1) {
        bool teamDeleted = await querier.deleteModel(team);
        if (!teamDeleted) {
          emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
          return;
        }
      } else {
        List<Player> teamMembers = List.of(team.players)..remove(player);
        Team teamWithoutPlayer = team.copyWith(players: teamMembers);
        Team? updatedTeam = await querier.updateModel(teamWithoutPlayer);
        if (updatedTeam == null) {
          emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
          return;
        }
        updatedCompetitionRegistrations.add(updatedTeam);
      }

      Competition competitionWithoutTeam = competition.copyWith(
        registrations: updatedCompetitionRegistrations,
      );
      Competition? updatedCompetition =
          await querier.updateModel(competitionWithoutTeam);
      if (updatedCompetition == null) {
        emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
        return;
      }
    }

    bool playerDeleted = await querier.deleteModel(player);
    if (!playerDeleted) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  void _onCompetitionCollectionUpdate(CollectionUpdateEvent event) {
    Competition competition = event.model as Competition;
    Iterable<Player> players = competition.registrations.expand(
      (team) => team.players,
    );
    if (players.contains(state.player)) {
      loadCompetitions();
    }
  }

  @override
  Future<void> close() {
    _competitionUpdateSubscription.cancel();
    return super.close();
  }
}
