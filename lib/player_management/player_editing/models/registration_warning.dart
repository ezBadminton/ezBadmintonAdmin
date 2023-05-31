import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/utils/gender_categories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

abstract class RegistrationWarning {
  String getWarningMessage(BuildContext context);
}

class AgeGroupWarning implements RegistrationWarning {
  AgeGroupWarning({
    required this.unfitAgeGroups,
    required Player player,
  }) : playerAge = player.calculateAge();

  final List<AgeGroup> unfitAgeGroups;
  final int playerAge;

  @override
  String getWarningMessage(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return l10n.ageGroupWarning(
      playerAge,
      display_strings.ageGroupList(l10n, unfitAgeGroups),
    );
  }
}

class PlayingLevelWarning implements RegistrationWarning {
  PlayingLevelWarning({
    required this.unfitPlayingLevels,
    required Player player,
  }) : playerLevel = player.playingLevel!;

  final List<PlayingLevel> unfitPlayingLevels;
  final PlayingLevel playerLevel;

  @override
  String getWarningMessage(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return l10n.playingLevelWarning(
      playerLevel.name,
      display_strings.playingLevelList(unfitPlayingLevels),
    );
  }
}

class GenderWarning implements RegistrationWarning {
  GenderWarning({
    required this.conflictingGender,
  });

  final GenderCategory conflictingGender;

  @override
  String getWarningMessage(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return l10n.genderWarning(
      l10n.genderCategory(conflictingGender.name),
      l10n.genderCategory(conflictingGender.opposite().name),
    );
  }
}
