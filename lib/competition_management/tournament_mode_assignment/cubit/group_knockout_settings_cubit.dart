import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/tournament_mode_settings_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/widgets/consolation_settings_handler.dart';

class GroupKnockoutSettingsCubit
    extends TournamentModeSettingsCubit<GroupKnockoutSettings>
    with ConsolationSettingsHandler<GroupKnockoutSettings> {
  GroupKnockoutSettingsCubit(super.initialState);

  void numGroupsChanged(int numGroups) {
    emit(
      state.copyWith(
        settings: state.settings.copyWith(numGroups: numGroups),
      ),
    );
  }

  void numQualificationsChanged(int numQualifications) {
    emit(
      state.copyWith(
        settings: state.settings.copyWith(numQualifications: numQualifications),
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

  void knockOutModeChanged(KnockOutMode knockOutMode) {
    emit(
      state.copyWith(
        settings: state.settings.copyWith(knockOutMode: knockOutMode),
      ),
    );
  }
}
