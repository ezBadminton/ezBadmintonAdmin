import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/tournament_bracket_explorer_controller.dart';
import 'package:flutter/material.dart';
import 'package:model_repository/model_repository.dart';

part 'bracket_explorer_state.dart';

class BracketExplorerCubit extends Cubit<BracketExplorerState> {
  BracketExplorerCubit() : super(BracketExplorerState());

  TournamentBracketExplorerController getViewController(
    Competition competition,
  ) {
    if (state.controllers.containsKey(competition)) {
      return state.controllers[competition]!;
    } else {
      TournamentBracketExplorerController newController =
          TournamentBracketExplorerController(GlobalKey());
      var newControllerMap = Map.of(state.controllers)
        ..putIfAbsent(competition, () => newController);
      emit(state.copyWith(controllers: newControllerMap));
      return newController;
    }
  }

  GlobalKey getBracketSectionKey(Object tournamentDataObject) {
    if (state.sectionKeys.containsKey(tournamentDataObject)) {
      return state.sectionKeys[tournamentDataObject]!;
    } else {
      GlobalKey newKey = GlobalKey();
      var newKeyMap = Map.of(state.sectionKeys)
        ..putIfAbsent(tournamentDataObject, () => newKey);
      emit(state.copyWith(sectionKeys: newKeyMap));
      return newKey;
    }
  }
}
