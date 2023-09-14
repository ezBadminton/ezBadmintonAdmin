import 'package:collection_repository/collection_repository.dart';

/// A wrapper for a [TournamentModeSettings] object.
///
/// Used to override the equality operator (`==`) by ID of the wrapped object.
/// Otherwise changes to the settings can't be detected by state listeners.
class TournamentModeSettingsState<M extends TournamentModeSettings> {
  TournamentModeSettingsState({
    required this.settings,
  });

  final M settings;

  TournamentModeSettingsState<M> copyWith({M? settings}) =>
      TournamentModeSettingsState(settings: settings ?? this.settings);
}
