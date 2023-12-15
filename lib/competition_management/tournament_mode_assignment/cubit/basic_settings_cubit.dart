import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/tournament_mode_settings_cubit.dart';

class BasicSettingsCubit<S extends TournamentModeSettings>
    extends TournamentModeSettingsCubit<S> {
  BasicSettingsCubit(super.initialState);

  void seedingModeChanged(SeedingMode seedingMode) {
    emit(
      state.copyWith(
        settings: state.settings.copyWith(seedingMode: seedingMode) as S,
      ),
    );
  }
}
