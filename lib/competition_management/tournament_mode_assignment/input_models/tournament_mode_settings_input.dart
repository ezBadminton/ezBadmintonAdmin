import 'package:collection_repository/collection_repository.dart';
import 'package:formz/formz.dart';

enum SettingsValidationError {
  noSettings,
  maxPointsIncompatible,
  winningPointsEmpty,
}

class TournamentModeSettingsInput
    extends FormzInput<TournamentModeSettings?, SettingsValidationError> {
  const TournamentModeSettingsInput.pure([super.value]) : super.pure();
  const TournamentModeSettingsInput.dirty([super.value]) : super.dirty();

  @override
  SettingsValidationError? validator(TournamentModeSettings? value) {
    if (value == null) {
      return SettingsValidationError.noSettings;
    }

    if (value.winningPoints == 0) {
      return SettingsValidationError.winningPointsEmpty;
    }

    if (value.twoPointMargin && value.winningPoints > value.maxPoints) {
      return SettingsValidationError.maxPointsIncompatible;
    }

    return null;
  }
}
