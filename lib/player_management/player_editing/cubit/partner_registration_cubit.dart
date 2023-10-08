import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/player_management/models/competition_registration.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/partner_registration_state.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';

class PartnerRegistrationCubit
    extends CollectionFetcherCubit<PartnerRegistrationState> {
  PartnerRegistrationCubit({
    required CompetitionRegistration registration,
    required CollectionRepository<Player> playerRepository,
    required CollectionRepository<Team> teamRepository,
    required CollectionRepository<Competition> competitionRepository,
  }) : super(
          PartnerRegistrationState(
            registration: registration,
            partner: SelectionInput.pure(value: registration.partner),
          ),
          collectionRepositories: [
            playerRepository,
            teamRepository,
            competitionRepository,
          ],
        ) {
    assert(
      registration.team.players.length < registration.competition.teamSize,
      'There is no space for registering a partner Player on this team',
    );
    loadPlayerData();
    subscribeToCollectionUpdates(
      teamRepository,
      _onTeamCollectionUpdate,
    );
    subscribeToCollectionUpdates(
      playerRepository,
      _onPlayerCollectionUpdate,
    );
    subscribeToCollectionUpdates(
      competitionRepository,
      _onCompetitionCollectionUpdate,
    );
  }

  void loadPlayerData() {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    fetchCollectionsAndUpdateState(
      [collectionFetcher<Player>()],
      onSuccess: (updatedState) {
        updatedState = updatedState.copyWith(
          loadingStatus: LoadingStatus.done,
        );
        emit(updatedState);
      },
      onFailure: () =>
          emit(state.copyWith(loadingStatus: LoadingStatus.failed)),
    );
  }

  void partnerInputVisibilityChanged(bool showPartnerInput) {
    var newState = state.copyWith(showPartnerInput: showPartnerInput);
    emit(newState);
  }

  void partnerChanged(Player? partner) {
    var newState = state.copyWith(
      partner: SelectionInput.dirty(emptyAllowed: true, value: partner),
    );
    emit(newState);
  }

  void partnerSubmitted() async {
    assert(state.partner.value != null);
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    Player partner = state.partner.value!;
    List<Player> teamMembers = List.of(state.registration.team.players)
      ..add(partner);
    Team teamWithPartner =
        state.registration.team.copyWith(players: teamMembers);

    CompetitionRegistration registrationWithPartner =
        state.registration.copyWith(team: teamWithPartner);

    // Check if partner is already on a solo team
    Team? existingPartnerTeam = registrationWithPartner.getPartnerTeam();
    if (existingPartnerTeam != null) {
      // Delete partner's solo team
      assert(existingPartnerTeam.players.length == 1);
      bool teamDeleted = await querier.deleteModel(existingPartnerTeam);
      if (!teamDeleted) {
        emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
        return;
      }
    }

    Team? updatedTeam = await querier.updateModel(teamWithPartner);
    if (updatedTeam == null && !isClosed) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    // The cubit might already be closed at this point because the
    // collection update events triggered widget tree updates
    if (!isClosed) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
    }
  }

  // If the currently selected partner is registered to another team
  // remove the selection to avoid double registrations
  void _onTeamCollectionUpdate(CollectionUpdateEvent<Team> event) {
    Team updatedTeam = event.model;
    if (state.partner.value != null &&
        updatedTeam.players.contains(state.partner.value)) {
      partnerChanged(null);
    }
  }

  void _onPlayerCollectionUpdate(CollectionUpdateEvent<Player> event) {
    Player updatedPlayer = event.model;
    switch (event.updateType) {
      case UpdateType.create:
      case UpdateType.delete:
        if (state.partner.value == updatedPlayer) {
          partnerChanged(null);
        }
        loadPlayerData();
        break;
      default:
        break;
    }
  }

  void _onCompetitionCollectionUpdate(
      CollectionUpdateEvent<Competition> event) {
    if (event.model.id == state.registration.competition.id) {
      CompetitionRegistration newRegistration =
          state.registration.copyWith(competition: event.model);

      emit(state.copyWith(registration: newRegistration));
    }
  }
}
