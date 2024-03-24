import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/player_management/models/competition_registration.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/partner_registration_state.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';

class PartnerRegistrationCubit
    extends CollectionQuerierCubit<PartnerRegistrationState> {
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

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    List<CollectionUpdateEvent<Model>> updateEvents,
  ) {
    bool doUpdate = updateEvents.isEmpty ||
        updateEvents
                .firstWhereOrNull((e) => e is CollectionUpdateEvent<Player>) !=
            null;

    if (!doUpdate) {
      return;
    }

    PartnerRegistrationState updatedState = state.copyWith(
      collections: collections,
      loadingStatus: LoadingStatus.done,
    );

    emit(updatedState);
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
  void _onTeamCollectionUpdate(List<CollectionUpdateEvent<Team>> events) {
    if (state.partner.value == null) {
      return;
    }

    bool partnerWasUpdated = events.firstWhereOrNull(
          (e) => e.model.players.contains(state.partner.value),
        ) !=
        null;

    if (partnerWasUpdated) {
      partnerChanged(null);
    }
  }

  void _onPlayerCollectionUpdate(List<CollectionUpdateEvent<Player>> events) {
    if (state.partner.value == null) {
      return;
    }

    CollectionUpdateEvent<Player>? updateEvent =
        events.reversed.firstWhereOrNull((e) => e.model == state.partner.value);

    if (updateEvent == null) {
      return;
    }

    partnerChanged(null);
  }

  void _onCompetitionCollectionUpdate(
    List<CollectionUpdateEvent<Competition>> events,
  ) {
    CollectionUpdateEvent<Competition>? updateEvent = events.reversed
        .firstWhereOrNull((e) => e.model == state.registration.competition);

    if (updateEvent == null) {
      return;
    }

    CompetitionRegistration newRegistration =
        state.registration.copyWith(competition: updateEvent.model);

    emit(state.copyWith(registration: newRegistration));
  }
}
