import 'package:collection_repository/collection_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

String ageGroup(AppLocalizations l10n, AgeGroup ageGroup) {
  return '${l10n.ageGroupAbbreviated(ageGroup.type.name)}${ageGroup.age}';
}

String ageGroupList(AppLocalizations l10n, List<AgeGroup> ageGroups) {
  return ageGroups.map((group) => ageGroup(l10n, group)).join(',');
}

String playingLevelList(List<PlayingLevel> playingLevels) {
  return playingLevels.map((lvl) => lvl.name).join(',');
}

String playerName(Player player) {
  return '${player.firstName} ${player.lastName}';
}

String playerWithClub(Player player) {
  var name = '${player.firstName} ${player.lastName}';
  var club = player.club == null ? '' : ' (${player.club!.name})';
  return name + club;
}

String competitionCategory(
  AppLocalizations l10n,
  CompetitionType type,
  GenderCategory genderCategory,
) {
  var genderPrefix = l10n.genderCategory(genderCategory.name);
  var competitionSuffix = l10n.competitionSuffix(type.name);
  return genderPrefix + competitionSuffix;
}
