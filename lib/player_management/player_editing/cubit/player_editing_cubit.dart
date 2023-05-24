import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/input_models/no_validation.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/competition_registration_state.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';

part 'player_editing_state.dart';

class PlayerEditingCubit extends CollectionQuerierCubit<PlayerEditingState> {
  PlayerEditingCubit({
    required BuildContext context,
    required CollectionRepository<Player> playerRepository,
    required CollectionRepository<Club> clubRepository,
    required CollectionRepository<Competition> competitionRepository,
    required CollectionRepository<Team> teamRepository,
    required this.players,
    required this.competitions,
    required this.playingLevels,
    required this.ageGroups,
    required this.clubs,
    required this.teams,
  })  : _context = context,
        super(
          PlayerEditingState.fromPlayer(
            player: Player.newPlayer(),
            context: context,
          ),
          collectionRepositories: [
            playerRepository,
            clubRepository,
            teamRepository,
            competitionRepository,
          ],
        );

  final BuildContext _context;

  final List<Player> players;
  final List<Competition> competitions;
  final List<PlayingLevel> playingLevels;
  final List<AgeGroup> ageGroups;
  final List<Club> clubs;
  final List<Team> teams;

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
  }

  void playingLevelChanged(PlayingLevel? playingLevel) {
    var newState = state.copyWith(
      playingLevel: SelectionInput.dirty(
        emptyAllowed: true,
        value: playingLevel,
      ),
    );
    emit(newState);
  }

  // Competition registration inputs

  void addRegistration() {
    int index = state.registrations.length;
    var newRegistrations = List.of(state.registrations)
      ..insert(index, CompetitionRegistrationState());
    emit(state.copyWith(registrations: newRegistrations));
  }

  void competitionTypeChanged(
    int registrationIndex,
    CompetitionType? competitionType,
  ) {
    var registration = state.registrations[registrationIndex];
    registration = registration.copyWith(
        competitionType: SelectionInput.dirty(value: competitionType));
    _emitRegistrationChange(registrationIndex, registration);
  }

  void competitionPlayingLevelChanged(
    int registrationIndex,
    PlayingLevel? playingLevel,
  ) {
    var registration = state.registrations[registrationIndex];
    registration = registration.copyWith(
        playingLevel: SelectionInput.dirty(value: playingLevel));
    _emitRegistrationChange(registrationIndex, registration);
  }

  void genderCategoryChanged(
    int registrationIndex,
    GenderCategory? genderCategory,
  ) {
    var registration = state.registrations[registrationIndex];
    registration = registration.copyWith(
        genderCategory: SelectionInput.dirty(value: genderCategory));
    _emitRegistrationChange(registrationIndex, registration);
  }

  void ageGroupChanged(
    int registrationIndex,
    AgeGroup? ageGroup,
  ) {
    var registration = state.registrations[registrationIndex];
    registration =
        registration.copyWith(ageGroup: SelectionInput.dirty(value: ageGroup));
    _emitRegistrationChange(registrationIndex, registration);
  }

  void partnerNameChanged(int registrationIndex, String partnerName) {
    var registration = state.registrations[registrationIndex];
    registration = registration.copyWith(
        partnerName: NoValidationInput.dirty(partnerName));
    _emitRegistrationChange(registrationIndex, registration);
  }

  void _emitRegistrationChange(
    int registrationIndex,
    CompetitionRegistrationState registration,
  ) {
    var newRegistrations = List.of(state.registrations)
      ..removeAt(registrationIndex)
      ..insert(registrationIndex, registration);
    emit(state.copyWith(registrations: newRegistrations));
  }

  // Competition registration options

  List<AgeGroup> getAvailableAgeGroups() {
    return competitions
        .map((c) => c.ageGroups)
        .expand((groups) => groups)
        .toSet()
        .sorted((a, b) => a.age > b.age ? 1 : -1);
  }

  List<PlayingLevel> getAvailablePlayingLevels() {
    return competitions
        .map((c) => c.playingLevels)
        .expand((levels) => levels)
        .toSet()
        .sorted((a, b) => a.index > b.index ? 1 : -1);
  }

  List<GenderCategory> getAvailableGenderCategories() {
    var presentGenderCategories = competitions.map((c) => c.genderCategory);
    return GenderCategory.values
        .where((t) => presentGenderCategories.contains(t))
        .toList();
  }

  List<CompetitionType> getAvailableCompetitionTypes() {
    var presentCompetitionTypes =
        competitions.map((c) => c.getCompetitionType());
    return CompetitionType.values
        .where((t) => presentCompetitionTypes.contains(t))
        .toList();
  }

  List<Competition> getSelectedCompetitions(int registrationIndex) {
    var registration = state.registrations[registrationIndex];
    return competitions.where((competition) {
      var typeMatch = competition.getCompetitionType() ==
          registration.competitionType.value;
      var genderCategoryMatch =
          competition.genderCategory == GenderCategory.any ||
              competition.genderCategory == registration.genderCategory.value;
      var ageGroupMatch = competition.ageGroups.isEmpty ||
          competition.ageGroups.contains(registration.ageGroup.value);
      var playingLevelMatch = competition.playingLevels.isEmpty ||
          competition.playingLevels.contains(registration.playingLevel.value);
      return typeMatch &&
          genderCategoryMatch &&
          ageGroupMatch &&
          playingLevelMatch;
    }).toList();
  }

  void formSubmitted() async {
    if (!state.isValid) {
      var newState = state.copyWith(formStatus: FormzSubmissionStatus.failure);
      emit(newState);
      return;
    }

    var newState = state.copyWith(
      formStatus: FormzSubmissionStatus.inProgress,
    );
    emit(newState);

    DateTime? dateOfBirth = state.dateOfBirth.value.isEmpty
        ? null
        : MaterialLocalizations.of(_context)
            .parseCompactDate(state.dateOfBirth.value);

    Club? club;
    if (state.clubName.value.isNotEmpty) {
      club = await _clubFromName(state.clubName.value);
      if (club == null) {
        emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
        return;
      }
    }

    Player editedPlayer = _applyChanges(
      dateOfBirth: dateOfBirth,
      club: club,
    );
    Player? createdPlayer = await querier.createModel(editedPlayer);
    if (createdPlayer == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }
    newState = state.copyWith(
      player: createdPlayer,
      formStatus: FormzSubmissionStatus.success,
    );
    emit(newState);
  }

  /// Either get an existing club by [clubName] or create a new one with the
  /// given [clubName].
  Future<Club?> _clubFromName(String clubName) async {
    Club? club;
    var selectedClub = clubs.where(
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

  Player _applyChanges({
    required DateTime? dateOfBirth,
    required Club? club,
  }) {
    return state.player.copyWith(
      firstName: state.firstName.value,
      lastName: state.lastName.value,
      eMail: state.eMail.value,
      dateOfBirth: dateOfBirth,
      playingLevel: state.playingLevel.value,
      club: club,
    );
  }
}
