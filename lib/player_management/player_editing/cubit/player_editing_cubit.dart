import 'dart:async';

import 'package:collection/collection.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/list_input.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/player_management/utils/competition_registration.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';

part 'player_editing_state.dart';

class PlayerEditingCubit extends CollectionQuerierCubit<PlayerEditingState> {
  PlayerEditingCubit({
    Player? player,
    required ModelStore<Player> playerStore,
    required ModelStore<Competition> competitionStore,
    required ModelStore<Registration> registrationStore,
    required ModelStore<TournamentEvent> tournamentStore,
    required ModelStore<Club> clubStore,
    required this.registerEndpoint,
    required this.updateTeamEndpoint,
  }) : super(
          PlayerEditingState(player: player),
          modelStores: [
            playerStore,
            competitionStore,
            registrationStore,
            tournamentStore,
            clubStore,
          ],
        ) {
    subscribeToCollectionUpdates(
      competitionStore,
      _onCompetitionCollectionUpdate,
    );
    subscribeToCollectionUpdates(
      competitionStore,
      _closeRegistrationFormOnUpdate,
    );
    subscribeToCollectionUpdates(
      tournamentStore,
      _closeRegistrationFormOnUpdate,
    );
  }

  final RegisterTeamEndpoint registerEndpoint;
  final UpdateTeamEndpoint updateTeamEndpoint;

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    List<CollectionUpdateEvent<Model>>? updateEvents,
  ) {
    PlayerEditingState updatedState = state.copyWith(
      collections: collections,
      loadingStatus: LoadingStatus.done,
    );

    if (state.player.id.isNotEmpty && state.isPure) {
      updatedState = updatedState.copyWithPlayer(
        player: state.player,
      );
    }

    List<Registration> playerRegistrations = registrationsOfPlayer(
      updatedState.player,
      updatedState.getCollection<Registration>(),
    );
    updatedState = updatedState.copyWith(
      registrations: ListInput.pure(playerRegistrations),
      loadingStatus: LoadingStatus.done,
    );

    if (updatedState.getCollection<Competition>().isEmpty &&
        state.registrationFormShown) {
      updatedState = updatedState.copyWith(registrationFormShown: false);
    }

    emit(updatedState);
  }

  // Personal data inputs

  void firstNameChanged(String firstName) {
    var newState =
        state.copyWith(firstName: NonEmptyInput.dirty(value: firstName));
    emit(newState);
  }

  void lastNameChanged(String lastName) {
    var newState =
        state.copyWith(lastName: NonEmptyInput.dirty(value: lastName));
    emit(newState);
  }

  void notesChanged(String notes) {
    var newState = state.copyWith(
      notes: NoValidationInput.dirty(notes),
    );
    emit(newState);
  }

  void clubNameChanged(String clubName) {
    var newState = state.copyWith(
        clubName: NoValidationInput.dirty(
      clubName,
    ));
    emit(newState);
  }

  void registrationFormOpened() {
    assert(!state.registrationFormShown);
    emit(state.copyWith(registrationFormShown: true));
  }

  void registrationCanceled() {
    assert(state.registrationFormShown);
    emit(state.copyWith(registrationFormShown: false));
  }

  /// Registers the Player for a new [registeredCompetition] in doubles
  /// disciplines with an optional [partner]
  void registrationAdded(
    Competition registeredCompetition,
    Player? partner,
  ) {
    assert(state.registrationFormShown);

    var team = Team.newTeam(players: [
      state.player,
      if (partner != null) partner,
    ]);

    assert(team.players.length <= registeredCompetition.teamSize);

    var registration = Registration.newRegistration(
      competition: registeredCompetition,
      team: team,
    );
    var registrations = state.registrations.copyWithAddedValue(registration);

    emit(state.copyWith(
      registrations: registrations,
      registrationFormShown: false,
    ));
  }

  void registrationRemoved(Registration removed) {
    assert(state.registrations.value.contains(removed));
    var registrations = state.registrations.copyWithRemovedValue(removed);
    emit(state.copyWith(registrations: registrations));
  }

  void formSubmitted() async {
    if (!state.isValid) {
      var newState = state.copyWith(formStatus: FormzSubmissionStatus.failure);
      emit(newState);
      return;
    }

    var progressState = state.copyWith(
      formStatus: FormzSubmissionStatus.inProgress,
    );
    emit(progressState);

    var updatedPlayerState = await _updateOrCreatePlayer(state);
    if (updatedPlayerState == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    bool registrationUpdate = await _updateRegistrations(updatedPlayerState);
    if (!registrationUpdate) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(updatedPlayerState.copyWith(
      formStatus: FormzSubmissionStatus.success,
    ));
  }

  Future<PlayerEditingState?> _updateOrCreatePlayer(
    PlayerEditingState state,
  ) async {
    Club? club;
    if (state.clubName.value.isNotEmpty) {
      club = _clubFromName(state.clubName.value);
    }

    Player editedPlayer = _applyPlayerChanges(
      club: club,
    );
    var updatedPlayer = await querier.updateOrCreateModel(editedPlayer);

    if (updatedPlayer == null) {
      return null;
    }

    return state.copyWith(
      player: updatedPlayer,
    );
  }

  /// Either get an existing club by [clubName] or create a new one with the
  /// given [clubName].
  Club _clubFromName(String clubName) {
    var lowerClubName = clubName.toLowerCase();
    Club? club = state.getCollection<Club>().firstWhereOrNull(
          (c) => c.name.toLowerCase() == lowerClubName,
        );
    if (club != null) {
      return club;
    }

    return Club.newClub(name: clubName);
  }

  /// Transfers the data from the form inputs to the Player object
  Player _applyPlayerChanges({
    Club? club,
  }) {
    return state.player.copyWith(
      firstName: state.firstName.value,
      lastName: state.lastName.value,
      notes: state.notes.value,
      clubRel: SingleRelation.fromModel(club),
    );
  }

  /// Updates the [Competition] and [Team] objects according to the newly
  /// added [CompetitionRegistration]s
  ///
  /// The List of [deregisteredCompetitions] represents the competitions that
  /// the player has been removed from during this form submit.
  List<Registration> _applyRegistrationAdditions(
    PlayerEditingState state,
  ) {
    assert(state.player.id.isNotEmpty);
    var addedRegistrations =
        state.registrations.getAddedElements().map((registration) {
      if (this.state.player.id.isEmpty) {
        // Replace new player with created player from db
        var teamMembers = List.of(registration.team.players)
          ..remove(this.state.player)
          ..add(state.player);

        var teamWithNewPlayer = registration.team.copyWith(
          playersRel: MultiRelation.fromModels(teamMembers),
        );
        registration = registration.copyWith(
          teamRel: SingleRelation.fromModel(teamWithNewPlayer),
        );
      }
      var registeredTeam =
          registration.getPartnerTeam(state.player) ?? registration.team;

      if (registeredTeam.id.isNotEmpty) {
        var teamMembers = List.of(registeredTeam.players)..add(state.player);
        registeredTeam = registeredTeam.copyWith(
          playersRel: MultiRelation.fromModels(teamMembers),
        );
      }

      return Registration.newRegistration(
        competition: registration.competition,
        team: registeredTeam,
      );
    }).toList();

    return addedRegistrations;
  }

  /// Persist the updated [Competition]s and [Team]s in their collections
  Future<bool> _updateRegistrations(
    PlayerEditingState state,
  ) async {
    List<Registration> removedRegistrations =
        state.registrations.getRemovedElements();

    for (var registration in removedRegistrations) {
      var partner = registration.getPartner(state.player);
      if (partner == null) {
        try {
          await updateTeamEndpoint.delete(pathParams: {
            "team": registration.team.id,
          });
        } catch (_) {
          return false;
        }
      } else {
        try {
          await updateTeamEndpoint.patch(
            pathParams: {"team": registration.team.id},
            body: {
              "players": [partner.id]
            },
          );
        } catch (_) {
          return false;
        }
      }
    }

    List<Registration> addedRegistrations = _applyRegistrationAdditions(state);

    for (var registration in addedRegistrations) {
      var playerIds = registration.team.players.map((p) => p.id).toList();
      if (registration.team.id.isEmpty) {
        try {
          await registerEndpoint.post(
            pathParams: {"competition": registration.competition.id},
            body: {"players": playerIds},
          );
        } catch (_) {
          return false;
        }
      } else {
        try {
          await updateTeamEndpoint.patch(
            pathParams: {"team": registration.team.id},
            body: {"players": playerIds},
          );
        } catch (_) {
          return false;
        }
      }
    }

    return true;
  }

  /// Reset the registration list when the competition collection
  /// changes while this form is open
  void _onCompetitionCollectionUpdate(List<CollectionUpdateEvent> _) {
    if (state.formStatus != FormzSubmissionStatus.success) {
      ListInput<Registration> resetRegistrations =
          state.registrations.copyWithReset();

      emit(state.copyWith(registrations: resetRegistrations));
    }
  }

  void _closeRegistrationFormOnUpdate(List<CollectionUpdateEvent> _) {
    if (state.registrationFormShown) {
      registrationCanceled();
    }
  }
}
