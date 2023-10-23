import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/tournament_mode_settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TournamentModeSettingsCubit<S extends TournamentModeSettings>
    extends Cubit<TournamentModeSettingsState<S>> {
  TournamentModeSettingsCubit(super.initialState);

  void winningPointsChanged(int winningPoints) {
    emit(state.copyWith(
      settings: state.settings.copyWith(winningPoints: winningPoints) as S,
    ));
  }

  void winningSetsChanged(int winningSets) {
    emit(state.copyWith(
      settings: state.settings.copyWith(winningSets: winningSets) as S,
    ));
  }

  void maxPointsChanged(int maxPoints) {
    emit(state.copyWith(
      settings: state.settings.copyWith(maxPoints: maxPoints) as S,
    ));
  }

  void twoPointMarginChanged(bool twoPointMargin) {
    emit(state.copyWith(
      settings: state.settings.copyWith(twoPointMargin: twoPointMargin) as S,
    ));
  }
}
