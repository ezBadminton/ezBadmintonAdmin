import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/tournament_mode_settings_cubit.dart';

class GroupKnockoutSettingsCubit
    extends TournamentModeSettingsCubit<GroupKnockoutSettings> {
  GroupKnockoutSettingsCubit(super.initialState);

  void numGroupsChanged(int numGroups) {
    emit(
      state.copyWith(
        settings: state.settings.copyWith(numGroups: numGroups),
      ),
    );
  }

  void qualificationsPerGroupChanged(int qualificationsPerGroup) {
    emit(
      state.copyWith(
        settings: state.settings
            .copyWith(qualificationsPerGroup: qualificationsPerGroup),
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
