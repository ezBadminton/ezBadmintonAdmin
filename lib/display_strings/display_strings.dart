import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/models/competition_category.dart';
import 'package:ez_badminton_admin_app/player_management/player_filter/player_filter.dart';
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
  String name = '${player.firstName} ${player.lastName}';
  String club = player.club == null ? '' : ' (${player.club!.name})';
  return name + club;
}

String competitionGenderAndType(
  AppLocalizations l10n,
  GenderCategory genderCategory,
  CompetitionType type,
) {
  String genderPrefix = l10n.genderCategory(genderCategory.name);
  String competitionSuffix = l10n.competitionSuffix(type.name);
  return genderPrefix + competitionSuffix;
}

String competitionGenderAndTypeAbbreviation(
  AppLocalizations l10n,
  GenderCategory genderCategory,
  CompetitionType type,
) {
  String genderPrefix = '';
  if (genderCategory != GenderCategory.mixed &&
      genderCategory != GenderCategory.any) {
    genderPrefix = genderCategory == GenderCategory.female
        ? l10n.womenAbbreviated
        : l10n.menAbbreviated;
  }

  String competitionSuffix = l10n.competitionTypeAbbreviated(type.name);

  return genderPrefix + competitionSuffix;
}

String competitionCategory(
  AppLocalizations l10n,
  CompetitionCategory competitionCategory,
) {
  return competitionGenderAndType(
    l10n,
    competitionCategory.genderCategory,
    competitionCategory.competitionType,
  );
}

String competitionCategoryAbbreviation(
  AppLocalizations l10n,
  CompetitionCategory competitionCategory,
) {
  return competitionGenderAndTypeAbbreviation(
    l10n,
    competitionCategory.genderCategory,
    competitionCategory.competitionType,
  );
}

String filterChipGroup(AppLocalizations l10n, FilterGroup filterGroup) {
  switch (filterGroup) {
    case FilterGroup.overAge:
    case FilterGroup.underAge:
      return l10n.age;
    case FilterGroup.playingLevel:
      return l10n.playingLevel(1);
    case FilterGroup.competitionType:
      return l10n.competition(1);
    case FilterGroup.genderCategory:
      return l10n.category;
    case FilterGroup.playerStatus:
      return l10n.status;
    case FilterGroup.search:
      return '';
  }
}

String filterChip(
  AppLocalizations l10n,
  FilterGroup filterGroup,
  String filterName,
) {
  switch (filterGroup) {
    case FilterGroup.overAge:
      String age = filterName.split(':').last;
      return l10n.overAgeAbbreviated + age;
    case FilterGroup.underAge:
      String age = filterName.split(':').last;
      return l10n.underAgeAbbreviated + age;
    case FilterGroup.playingLevel:
      return filterName;
    case FilterGroup.competitionType:
      return l10n.competitionType(filterName);
    case FilterGroup.genderCategory:
      return l10n.genderCategory(filterName);
    case FilterGroup.playerStatus:
      return l10n.playerStatus(filterName);
    case FilterGroup.search:
      return '';
  }
}
