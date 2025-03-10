import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/partner_registration_state.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';

class PartnerRegistrationCubit
    extends CollectionQuerierCubit<PartnerRegistrationState> {
  PartnerRegistrationCubit({
    required Player player,
    required Registration registration,
    required ModelStore<Player> playerRepository,
    required ModelStore<Team> teamRepository,
    required this.updateTeamEndpoint,
  }) : super(
          PartnerRegistrationState(
            player: player,
            registration: registration,
            partner: SelectionInput.pure(
              value: registration.getPartner(player),
            ),
          ),
          modelStores: [
            playerRepository,
            teamRepository,
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
  }

  final UpdateTeamEndpoint updateTeamEndpoint;

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    CollectionUpdateEvent<Model>? updateEvent,
  ) {
    bool doUpdate =
        updateEvent == null || updateEvent is CollectionUpdateEvent<Player>;
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
    Team teamWithPartner = state.registration.team
        .copyWith(playersRel: MultiRelation.fromModels(teamMembers));

    Registration registrationWithPartner = state.registration.copyWith(
      teamRel: SingleRelation.fromModel(teamWithPartner),
    );

    // Check if partner is already on a solo team
    Team? existingPartnerTeam =
        registrationWithPartner.getPartnerTeam(state.player);
    if (existingPartnerTeam != null) {
      try {
        await updateTeamEndpoint.delete(pathParams: {
          "team": existingPartnerTeam.id,
        });
      } catch (_) {
        emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
        return;
      }
    }

    var playerIds = teamMembers.map((p) => p.id).toList();
    try {
      await updateTeamEndpoint.patch(
        pathParams: {"team": teamWithPartner.id},
        body: {"players": playerIds},
      );
    } catch (_) {
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
    if (state.partner.value == null) {
      return;
    }

    bool partnerWasUpdated = event.model.players.contains(state.partner.value);
    if (partnerWasUpdated) {
      partnerChanged(null);
    }
  }

  void _onPlayerCollectionUpdate(CollectionUpdateEvent<Player> event) {
    if (state.partner.value == null) {
      return;
    }
    if (event.model == state.partner.value) {
      partnerChanged(null);
    }
  }
}
