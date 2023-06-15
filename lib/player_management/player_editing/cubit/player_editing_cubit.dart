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
    Player? player,
    required CollectionRepository<Player> playerRepository,
    required CollectionRepository<Competition> competitionRepository,
    required CollectionRepository<Club> clubRepository,
    required CollectionRepository<PlayingLevel> playingLevelRepository,
    required CollectionRepository<Team> teamRepository,
  })  : _context = context,
        super(
          PlayerEditingState(player: player),
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
        if (state.player.id.isNotEmpty && state.isPure) {
          updatedState = updatedState.copyWithPlayer(
            player: state.player,
            dateParser: dateParser,
          );
        }

        var playerCompetitions = mapCompetitionRegistrations(
          updatedState.getCollection<Player>(),
          updatedState.getCollection<Competition>(),
        );
        updatedState = updatedState.copyWith(
          registrations:
              ListInput.pure(playerCompetitions[updatedState.player] ?? []),
          loadingStatus: LoadingStatus.done,
        );
        if (state.player.dateOfBirth != null) {
          var dobString = dateFormatter(state.player.dateOfBirth!);
          updatedState = updatedState.copyWith(
            dateOfBirth: DateInput.pure(
              dateParser: dateParser,
              emptyAllowed: true,
              value: dobString,
            ),
          );
        }
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

  void dateOfBirthChanged(String dateOfBirth) {
    var newState = state.copyWith(
      dateOfBirth: DateInput.dirty(
        dateParser: dateParser,
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

    var registration = CompetitionRegistration(
      player: state.player,
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
      club = await _clubFromName(state.clubName.value);
      if (club == null) {
        return null;
      }
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

  /// Transfers the data from the form inputs to the Player object
  Player _applyPlayerChanges({
    Club? club,
  }) {
    DateTime? dateOfBirth =
        state.dateOfBirth.value.isEmpty || state.dateOfBirth.isNotValid
            ? null
            : dateParser(state.dateOfBirth.value);
    return state.player.copyWith(
      firstName: state.firstName.value,
      lastName: state.lastName.value,
      notes: state.notes.value,
      dateOfBirth: dateOfBirth,
      playingLevel: state.playingLevel.value,
      club: club,
    );
  }

  /// Updates the [Competition] and [Team] objects according to the newly
  /// added [CompetitionRegistration]s
  ///
  /// The List of [deregisteredCompetitions] represents the competitions that
  /// the player has been removed from during this form submit.
  List<CompetitionRegistration> _applyRegistrationAdditions(
    PlayerEditingState state,
    List<Competition> deregisteredCompetitions,
  ) {
    assert(state.player.id.isNotEmpty);
    var addedRegistrations =
        state.registrations.getAddedElements().map((registration) {
      // Use updated competition object if player has been removed from it
      var deregisteredCompetition = deregisteredCompetitions
          .where((c) => c == registration.competition)
          .firstOrNull;
      var competition = deregisteredCompetition ?? registration.competition;
      var registeredTeam = registration.team;
      assert(registeredTeam.id.isEmpty);

      if (this.state.player.id.isEmpty) {
        // Replace new player with created player from db
        var teamMembers = List.of(registeredTeam.players)
          ..remove(this.state.player)
          ..add(state.player);

        registeredTeam = registeredTeam.copyWith(players: teamMembers);
      }

      if (registeredTeam.players.length == 2) {
        // Check if partner already has a team
        var partner = registration.partner!;
        var partnerTeam = registration.getPartnerTeam();
        if (partnerTeam != null) {
          assert(
            partnerTeam.players.length == 1,
            'registration form selected partner that already has a partner',
          );
          registeredTeam = partnerTeam.copyWith(
            players: [partner, state.player],
          );
        }
      }

      return CompetitionRegistration(
        player: state.player,
        competition: competition,
        team: registeredTeam,
      );
    }).toList();

    return addedRegistrations;
  }

  /// Updates the [Competition] and [Team] objects according to the removed
  /// [CompetitionRegistration]s
  List<CompetitionRegistration> _applyRegistrationRemovals(
    PlayerEditingState state,
  ) {
    assert(state.player.id.isNotEmpty);
    var removedRegistrations =
        state.registrations.getRemovedElements().map((registration) {
      var competition = registration.competition;
      var leftTeam = registration.team;
      assert(
        leftTeam.players.contains(state.player),
        'tried to remove non-existent registration',
      );
      assert(leftTeam.id.isNotEmpty);

      var teamMembers = List.of(leftTeam.players)..remove(state.player);
      leftTeam = leftTeam.copyWith(players: teamMembers);

      return CompetitionRegistration(
        player: state.player,
        competition: competition,
        team: leftTeam,
      );
    }).toList();

    return removedRegistrations;
  }

  /// Persist the updated [Competition]s and [Team]s in their collections
  Future<bool> _updateRegistrations(
    PlayerEditingState state,
  ) async {
    var removedRegistrations = _applyRegistrationRemovals(state);
    var deregisteredCompetitions = <Competition>[];

    for (var registration in removedRegistrations) {
      var competition = registration.competition;
      var leftTeam = registration.team;
      List<Team> updatedTeams;
      if (leftTeam.players.isEmpty) {
        var teamDeleted = await querier.deleteModel(leftTeam);
        if (!teamDeleted) {
          return false;
        }
        updatedTeams = List.of(registration.competition.registrations)
          ..remove(leftTeam);
      } else {
        var updatedTeam = await querier.updateModel(leftTeam);
        if (updatedTeam == null) {
          return false;
        }
        updatedTeams = List.of(registration.competition.registrations)
          ..remove(leftTeam)
          ..add(updatedTeam);
      }
      competition = competition.copyWith(registrations: updatedTeams);
      Competition? updatedCompetition = await querier.updateModel(competition);
      if (updatedCompetition == null) {
        return false;
      }
      deregisteredCompetitions.add(updatedCompetition);
    }

    var addedRegistrations = _applyRegistrationAdditions(
      state,
      deregisteredCompetitions,
    );

    for (var registration in addedRegistrations) {
      var competition = registration.competition;
      var joinedTeam = registration.team;
      if (competition.registrations
          .expand((team) => team.players)
          .contains(state.player)) {
        // Tried to register Player twice
        return false;
      }
      var updatedTeam = await querier.updateOrCreateModel(joinedTeam);
      if (updatedTeam == null) {
        return false;
      }
      var updatedTeams = List.of(competition.registrations)
        ..remove(joinedTeam)
        ..add(updatedTeam);
      competition = competition.copyWith(
        registrations: updatedTeams,
      );
      var updatedCompetition = await querier.updateModel(competition);
      if (updatedCompetition == null) {
        return false;
      }
    }

    return true;
  }

  String Function(DateTime) get dateFormatter =>
      MaterialLocalizations.of(_context).formatCompactDate;

  DateTime? Function(String) get dateParser {
    return MaterialLocalizations.of(_context).parseCompactDate;
  }
}
