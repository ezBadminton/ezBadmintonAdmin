import 'dart:async';

import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/list_input.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/input_models/no_validation.dart';
import 'package:ez_badminton_admin_app/player_management/models/competition_registration.dart';
import 'package:ez_badminton_admin_app/player_management/utils/competition_registration.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';

part 'player_editing_state.dart';

class PlayerEditingCubit extends CollectionFetcherCubit<PlayerEditingState> {
  PlayerEditingCubit({
    required BuildContext context,
    required CollectionRepository<Player> playerRepository,
    required CollectionRepository<Competition> competitionRepository,
    required CollectionRepository<Club> clubRepository,
    required CollectionRepository<PlayingLevel> playingLevelRepository,
    required CollectionRepository<Team> teamRepository,
  })  : _context = context,
        super(
          PlayerEditingState.fromPlayer(
            player: Player.newPlayer(),
            context: context,
          ),
          collectionRepositories: [
            playerRepository,
            competitionRepository,
            clubRepository,
            playingLevelRepository,
            teamRepository,
          ],
        ) {
    loadPlayerData();
  }

  final BuildContext _context;

  void loadPlayerData() {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    fetchCollectionsAndUpdateState(
      [
        collectionFetcher<Player>(),
        collectionFetcher<Competition>(),
        collectionFetcher<Club>(),
        collectionFetcher<PlayingLevel>(),
      ],
      onSuccess: (updatedState) {
        var playerCompetitions = mapCompetitionRegistrations(
          updatedState.getCollection<Player>(),
          updatedState.getCollection<Competition>(),
        );
        updatedState = updatedState.copyWith(
          registrations:
              ListInput.pure(playerCompetitions[updatedState.player] ?? []),
          loadingStatus: LoadingStatus.done,
        );
        emit(updatedState);
      },
      onFailure: () =>
          emit(state.copyWith(loadingStatus: LoadingStatus.failed)),
    );
  }

  // Personal data inputs

  void firstNameChanged(String firstName) {
    var newState = state.copyWith(firstName: NonEmptyInput.dirty(firstName));
    emit(newState);
  }

  void lastNameChanged(String lastName) {
    var newState = state.copyWith(lastName: NonEmptyInput.dirty(lastName));
    emit(newState);
  }

  void eMailChanged(String eMail) {
    var newState = state.copyWith(
      eMail: EMailInput.dirty(emptyAllowed: true, value: eMail),
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

  void dateOfBirthChanged(String dateOfBirth) {
    var newState = state.copyWith(
      dateOfBirth: DateInput.dirty(
        context: _context,
        emptyAllowed: true,
        value: dateOfBirth,
      ),
    );
    emit(newState);
    emit(state.copyWith(player: _applyPlayerChanges()));
  }

  void playingLevelChanged(PlayingLevel? playingLevel) {
    var newState = state.copyWith(
      playingLevel: SelectionInput.dirty(
        emptyAllowed: true,
        value: playingLevel,
      ),
    );
    emit(newState);
    emit(state.copyWith(player: _applyPlayerChanges()));
  }

  void registrationFormOpened() {
    assert(!state.registrationFormShown);
    emit(state.copyWith(registrationFormShown: true));
  }

  void registrationCancelled() {
    assert(state.registrationFormShown);
    emit(state.copyWith(registrationFormShown: false));
  }

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

    var registration = CompetitionRegistration(
      competition: registeredCompetition,
      team: team,
    );
    var registrations = state.registrations.copyWithAddedValue(registration);

    emit(state.copyWith(
      registrations: registrations,
      registrationFormShown: false,
    ));
  }

  void registrationRemoved(CompetitionRegistration removedCompetition) {
    assert(state.registrations.value.contains(removedCompetition));
    var registrations =
        state.registrations.copyWithRemovedValue(removedCompetition);
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
      return;
    }

    bool registrationUpdate = await _updateRegistrations(updatedPlayerState);
    if (!registrationUpdate) {
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
      club = await _clubFromName(state.clubName.value);
      if (club == null) {
        emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
        return null;
      }
    }

    Player editedPlayer = _applyPlayerChanges(
      club: club,
    );
    var updatedPlayer = await querier.updateOrCreateModel(editedPlayer);

    if (updatedPlayer == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return null;
    }

    return state.copyWith(
      player: updatedPlayer,
    );
  }

  /// Either get an existing club by [clubName] or create a new one with the
  /// given [clubName].
  Future<Club?> _clubFromName(String clubName) async {
    Club? club;
    var selectedClub = state.getCollection<Club>().where(
          (c) => c.name.toLowerCase() == clubName.toLowerCase(),
        );
    if (selectedClub.isNotEmpty) {
      club = selectedClub.first;
    } else {
      var createdClub = Club.newClub(name: clubName);
      club = await querier.createModel(createdClub);
    }
    return club;
  }

  Player _applyPlayerChanges({
    Club? club,
  }) {
    DateTime? dateOfBirth =
        state.dateOfBirth.value.isEmpty || state.dateOfBirth.isNotValid
            ? null
            : MaterialLocalizations.of(_context)
                .parseCompactDate(state.dateOfBirth.value);
    return state.player.copyWith(
      firstName: state.firstName.value,
      lastName: state.lastName.value,
      eMail: state.eMail.value,
      dateOfBirth: dateOfBirth,
      playingLevel: state.playingLevel.value,
      club: club,
    );
  }

  List<CompetitionRegistration> _applyRegistrationChanges(
    PlayerEditingState state,
  ) {
    assert(state.player.id.isNotEmpty);
    var addedRegistrations =
        state.registrations.getAddedElements().map((registration) {
      var competition = registration.competition;
      var registeredTeam = registration.team;

      if (this.state.player.id.isEmpty) {
        // Replace new player with created player from db

        var createdPlayers = List.of(registeredTeam.players)
          ..remove(this.state.player)
          ..add(state.player);

        registeredTeam = registeredTeam.copyWith(players: createdPlayers);
      }

      if (registeredTeam.players.length == 2) {
        // Check if partner already has a team
        var partner =
            registeredTeam.players.whereNot((p) => p == state.player).first;
        var partnerTeam = competition.registrations
            .where((t) => t.players.contains(partner))
            .firstOrNull;
        if (partnerTeam != null) {
          assert(partnerTeam.players.length == 1);
          registeredTeam = partnerTeam.copyWith(
            players: [partner, state.player],
          );
        }
      }

      return CompetitionRegistration(
        competition: competition,
        team: registeredTeam,
      );
    }).toList();

    return addedRegistrations;
  }

  Future<bool> _updateRegistrations(
    PlayerEditingState state,
  ) async {
    var registrations = _applyRegistrationChanges(state);
    for (var registration in registrations) {
      var updatedTeam = await querier.updateOrCreateModel(registration.team);
      if (updatedTeam == null) {
        emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
        return false;
      }
      var updatedTeams = List.of(registration.competition.registrations)
        ..remove(registration.team)
        ..add(updatedTeam);
      var competition = registration.competition.copyWith(
        registrations: updatedTeams,
      );
      var updatedCompetition = await querier.updateModel(competition);
      if (updatedCompetition == null) {
        emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
        return false;
      }
    }
    return true;
  }
}
