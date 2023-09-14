import 'package:bloc/bloc.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/tournament_mode_settings_state.dart';

class RoundRobinSettingsCubit
    extends Cubit<TournamentModeSettingsState<RoundRobinSettings>> {
  RoundRobinSettingsCubit(super.initialState);

  void passesChanged(int passes) {
    emit(
      state.copyWith(
        settings: state.settings.copyWith(passes: passes),
      ),
    );
  }
}
