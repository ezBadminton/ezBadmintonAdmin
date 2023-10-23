import 'package:collection_repository/collection_repository.dart';
import 'package:formz/formz.dart';

enum SettingsValidationError {
  noSettings,
  maxPointsIncompatible,
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

    if (value.twoPointMargin && value.winningPoints > value.maxPoints) {
      return SettingsValidationError.maxPointsIncompatible;
    }

    return null;
  }
}
