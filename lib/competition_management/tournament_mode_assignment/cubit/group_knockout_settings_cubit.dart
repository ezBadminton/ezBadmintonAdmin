import 'package:bloc/bloc.dart';
import 'package:collection_repository/collection_repository.dart';

class GroupKnockoutSettingsCubit extends Cubit<GroupKnockoutSettings> {
  GroupKnockoutSettingsCubit(super.initialState);

  void numGroupsChanged(int numGroups) {
    emit(state.copyWith(numGroups: numGroups));
  }

  void qualificationsPerGroupChanged(int qualificationsPerGroup) {
    emit(state.copyWith(qualificationsPerGroup: qualificationsPerGroup));
  }

  void seedingModeChanged(SeedingMode seedingMode) {
    emit(state.copyWith(seedingMode: seedingMode));
  }
}
