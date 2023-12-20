import 'package:collection_repository/collection_repository.dart';
import 'package:formz/formz.dart';

enum SettingsValidationError {
  noSettings,
  maxPointsIncompatible,
  winningPointsEmpty,
  tooFewPlacesToPlayOut,
}

class TournamentModeSettingsInput
    extends FormzInput<TournamentModeSettings?, SettingsValidationError> {
  const TournamentModeSettingsInput.pure([super.value]) : super.pure();
  const TournamentModeSettingsInput.dirty([super.value]) : super.dirty();

  @override
  SettingsValidationError? validator(TournamentModeSettings? value) {
    switch (value) {
      case null:
        return SettingsValidationError.noSettings;
      case TournamentModeSettings(winningPoints: == 0):
        return SettingsValidationError.winningPointsEmpty;
      case SingleEliminationWithConsolationSettings(placesToPlayOut: < 2):
        return SettingsValidationError.tooFewPlacesToPlayOut;
      case TournamentModeSettings(twoPointMargin: true):
        bool incompatible = value.winningPoints > value.maxPoints;
        if (incompatible) {
          return SettingsValidationError.maxPointsIncompatible;
        }
      default:
        break;
    }

    return null;
  }
}
