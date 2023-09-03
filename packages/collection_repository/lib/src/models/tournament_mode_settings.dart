import 'package:collection_repository/collection_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/tournament_mode_settings.freezed.dart';
part 'generated/tournament_mode_settings.g.dart';

/// A class for storing the settings of a tournament mode.
///
/// For each of the different modes there is a union type with its settings.
@Freezed(unionKey: 'type', unionValueCase: FreezedUnionCase.pascal)
class TournamentModeSettings extends Model with _$TournamentModeSettings {
  const TournamentModeSettings._();

  @FreezedUnionValue('RoundRobin')
  const factory TournamentModeSettings.roundRobin({
    required String id,
    required DateTime created,
    required DateTime updated,
    required SeedingMode seedingMode,
    required int passes,
  }) = RoundRobinSettings;

  @FreezedUnionValue('SingleElimination')
  const factory TournamentModeSettings.singleElimination({
    required String id,
    required DateTime created,
    required DateTime updated,
    required SeedingMode seedingMode,
  }) = SingleEliminationSettings;

  @FreezedUnionValue('GroupKnockout')
  const factory TournamentModeSettings.groupKnockout({
    required String id,
    required DateTime created,
    required DateTime updated,
    required SeedingMode seedingMode,
    required int numGroups,
    required int qualificationsPerGroup,
  }) = GroupKnockoutSettings;

  factory TournamentModeSettings.fromJson(Map<String, dynamic> json) =>
      _$TournamentModeSettingsFromJson(json);

  @override
  Map<String, dynamic> toCollapsedJson() {
    return toJson();
  }
}

enum SeedingMode {
  random,
  single,
  tiered,
}
