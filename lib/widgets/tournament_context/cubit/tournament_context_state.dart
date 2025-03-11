part of 'tournament_context_cubit.dart';

class TournamentContextState {
  TournamentContextState(this.tournamentGetter);
  final Tournament Function(TournamentPlan plan) tournamentGetter;
}
