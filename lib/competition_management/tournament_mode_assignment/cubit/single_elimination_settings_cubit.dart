import 'package:bloc/bloc.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/tournament_mode_settings_state.dart';

class SingleEliminationSettingsCubit
    extends Cubit<TournamentModeSettingsState<SingleEliminationSettings>> {
  SingleEliminationSettingsCubit(super.initialState);

  void seedingModeChanged(SeedingMode seedingMode) {
    emit(
      state.copyWith(
        settings: state.settings.copyWith(seedingMode: seedingMode),
      ),
    );
  }
}
