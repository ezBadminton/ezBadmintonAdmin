import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/tournament_mode_settings_cubit.dart';

mixin ConsolationSettingsHandler<S extends TournamentModeSettings>
    on TournamentModeSettingsCubit<S> {
  void numConsolationRoundsChanged(int numConsolationRounds) {
    _applySetting(numConsolationRounds: numConsolationRounds);
  }

  void placesToPlayOutChanged(int placesToPlayOut) {
    _applySetting(placesToPlayOut: placesToPlayOut);
  }

  void _applySetting({
    int? numConsolationRounds,
    int? placesToPlayOut,
  }) {
    TournamentModeSettings newSettings = switch (state.settings) {
      SingleEliminationWithConsolationSettings s => s.copyWith(
          numConsolationRounds: numConsolationRounds ?? s.numConsolationRounds,
          placesToPlayOut: placesToPlayOut ?? s.placesToPlayOut,
        ),
      GroupKnockoutSettings s => s.copyWith(
          numConsolationRounds: numConsolationRounds ?? s.numConsolationRounds,
          placesToPlayOut: placesToPlayOut ?? s.placesToPlayOut,
        ),
      _ => throw (
          "This TournamentModeSettingsCubit can not handle consolation settings",
        ),
    };

    emit(state.copyWith(settings: newSettings as S));
  }
}
