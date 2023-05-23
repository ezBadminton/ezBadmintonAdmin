import 'package:bloc/bloc.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/input_models/no_validation.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';

part 'player_editing_state.dart';

class PlayerEditingCubit extends Cubit<PlayerEditingState> {
  PlayerEditingCubit({
    required BuildContext context,
    required CollectionRepository<Player> playerRepository,
    required CollectionRepository<Club> clubRepository,
    required CollectionRepository<Competition> competitionRepository,
    required CollectionRepository<Team> teamRepository,
    required List<Player> players,
    required List<PlayingLevel> playingLevels,
    required List<Club> clubs,
    required List<Competition> competitions,
    required List<Team> teams,
  })  : _context = context,
        _playerRepository = playerRepository,
        _clubRepository = clubRepository,
        _teamRepository = teamRepository,
        _competitionRepository = competitionRepository,
        super(PlayerEditingState.fromPlayer(
          player: Player.newPlayer(),
          context: context,
          playingLevels: playingLevels,
          clubs: clubs,
        ));

  final BuildContext _context;
  final CollectionRepository<Player> _playerRepository;
  final CollectionRepository<Club> _clubRepository;
  final CollectionRepository<Competition> _competitionRepository;
  final CollectionRepository<Team> _teamRepository;

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

  void competitionTypeChanged(CompetitionType? competitionType) {
    if (competitionType == CompetitionType.mixed) {
      genderCategoryChanged(GenderCategory.mixed);
    } else if (state.genderCategory.value == GenderCategory.mixed) {
      genderCategoryChanged(GenderCategory.male);
    }
    var newState = state.copyWith(
      competitionType: SelectionInput.dirty(
        emptyAllowed: true,
        value: competitionType,
      ),
    );
    emit(newState);
  }

  void genderCategoryChanged(GenderCategory genderCategory) {
    var newState = state.copyWith(
      genderCategory: SelectionInput.dirty(value: genderCategory),
    );
    emit(newState);
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
      var selectedClub = state.clubs.where(
        (c) => c.name.toLowerCase() == state.clubName.value.toLowerCase(),
      );
      if (selectedClub.isNotEmpty) {
        club = selectedClub.first;
      } else {
        var createdClub = Club.newClub(name: state.clubName.value);
        club = await _clubRepository.create(createdClub);
      }
    }
    Player editedPlayer = _applyChanges(
      dateOfBirth: dateOfBirth,
      club: club,
    );
    Player createdPlayer = await _playerRepository.create(editedPlayer);
    newState = state.copyWith(
      player: createdPlayer,
      formStatus: FormzSubmissionStatus.success,
    );
    emit(newState);
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
