import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/tournament_mode_settings_cubit.dart';

class ConsolationSettingsCubit extends TournamentModeSettingsCubit<
    SingleEliminationWithConsolationSettings> {
  ConsolationSettingsCubit(super.initialState);

  void numConsolationRoundsChanged(int numConsolationRounds) {
    emit(
      state.copyWith(
        settings: state.settings.copyWith(
          numConsolationRounds: numConsolationRounds,
        ),
      ),
    );
  }

  void placesToPlayOutChanged(int placesToPlayOut) {
    emit(
      state.copyWith(
        settings: state.settings.copyWith(placesToPlayOut: placesToPlayOut),
      ),
    );
  }

  void seedingModeChanged(SeedingMode seedingMode) {
    emit(
      state.copyWith(
        settings: state.settings.copyWith(seedingMode: seedingMode),
      ),
    );
  }
}
