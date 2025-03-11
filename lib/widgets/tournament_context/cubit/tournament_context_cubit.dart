import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model_repository/model_repository.dart';

part 'tournament_context_state.dart';

class TournamentContextCubit extends Cubit<TournamentContextState> {
  TournamentContextCubit(
    Tournament Function(TournamentPlan plan) tournamentGetter,
  ) : super(TournamentContextState(tournamentGetter));
}
