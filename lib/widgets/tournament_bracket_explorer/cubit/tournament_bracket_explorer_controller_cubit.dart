import 'package:bloc/bloc.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/tournament_bracket_explorer_controller.dart';
import 'package:flutter/material.dart';

class TournamentBracketExplorerControllerCubit
    extends Cubit<Map<Competition, TournamentBracketExplorerController>> {
  TournamentBracketExplorerControllerCubit() : super(const {});

  TournamentBracketExplorerController getViewController(
    Competition competition,
  ) {
    if (state.containsKey(competition)) {
      return state[competition]!;
    } else {
      TournamentBracketExplorerController newController =
          TournamentBracketExplorerController(GlobalKey());
      var newState = Map.of(state)
        ..putIfAbsent(competition, () => newController);
      emit(newState);
      return newController;
    }
  }
}
