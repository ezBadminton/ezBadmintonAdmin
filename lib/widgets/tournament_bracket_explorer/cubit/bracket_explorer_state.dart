// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'bracket_explorer_cubit.dart';

class BracketExplorerState {
  BracketExplorerState({
    this.controllers = const {},
    this.sectionKeys = const {},
  });

  final Map<Competition, TournamentBracketExplorerController> controllers;
  final Map<Object, GlobalKey> sectionKeys;

  BracketExplorerState copyWith({
    Map<Competition, TournamentBracketExplorerController>? controllers,
    Map<Object, GlobalKey>? sectionKeys,
  }) {
    return BracketExplorerState(
      controllers: controllers ?? this.controllers,
      sectionKeys: sectionKeys ?? this.sectionKeys,
    );
  }
}
