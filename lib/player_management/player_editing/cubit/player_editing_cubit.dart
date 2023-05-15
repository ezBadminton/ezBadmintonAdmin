import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:flutter/material.dart';

part 'player_editing_state.dart';

class PlayerEditingCubit extends Cubit<PlayerEditingState> {
  PlayerEditingCubit({
    required BuildContext context,
    required CollectionRepository<Player> playerRepository,
    required CollectionRepository<PlayingLevel> playingLevelRepository,
    required CollectionRepository<Club> clubRepository,
    required CollectionRepository<Competition> competitionRepository,
    required CollectionRepository<Team> teamRepository,
  })  : _teamRepository = teamRepository,
        _competitionRepository = competitionRepository,
        _clubRepository = clubRepository,
        _playingLevelRepository = playingLevelRepository,
        _playerRepository = playerRepository,
        _context = context,
        super(PlayerEditingState.fromPlayer(context: context)) {
    _populatePlayingLevelList();
    _populateClubList();
  }

  final BuildContext _context;
  final CollectionRepository<Player> _playerRepository;
  final CollectionRepository<PlayingLevel> _playingLevelRepository;
  final CollectionRepository<Club> _clubRepository;
  final CollectionRepository<Competition> _competitionRepository;
  final CollectionRepository<Team> _teamRepository;

  void _populatePlayingLevelList() async {
    var playingLevels = await _playingLevelRepository.getList();
    var newState = state.copyWith(playingLevels: playingLevels);
    emit(newState);
  }

  void _populateClubList() async {
    var clubs = await _clubRepository.getList();
    var newState = state.copyWith(clubs: clubs);
    emit(newState);
  }

  void firstNameChanged(String firstName) {
    var newState = state.copyWith(firstName: NonEmptyInput.dirty(firstName));
    emit(newState);
  }

  void lastNameChanged(String lastName) {
    var newState = state.copyWith(lastName: NonEmptyInput.dirty(lastName));
    emit(newState);
  }

  void eMailChanged(String eMail) {
    var newState = state.copyWith(eMail: EMailInput.dirty(eMail));
    emit(newState);
  }

  void clubNameChanged(String clubName) {
    var newState = state.copyWith(clubName: NonEmptyInput.dirty(clubName));
    emit(newState);
  }

  void dateOfBirthChanged(String dateOfBirth) {
    var newState = state.copyWith(
      dateOfBirth: DateInput.dirty(
        context: _context,
        value: dateOfBirth,
      ),
    );
    emit(newState);
  }
}
