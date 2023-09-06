import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/models/competition_category.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate_producers.dart';
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
  CompetitionDiscipline competitionCategory,
) {
  return competitionGenderAndType(
    l10n,
    competitionCategory.genderCategory,
    competitionCategory.competitionType,
  );
}

String competitionCategoryAbbreviation(
  AppLocalizations l10n,
  CompetitionDiscipline competitionCategory,
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
    case FilterGroup.ageGroup:
      return l10n.ageGroup(1);
    case FilterGroup.playingLevel:
      return l10n.playingLevel(1);
    case FilterGroup.competitionType:
      return l10n.competition(1);
    case FilterGroup.genderCategory:
      return l10n.category;
    case FilterGroup.playerStatus:
      return l10n.status;
    case FilterGroup.playerSearch:
      return '';
    case FilterGroup.moreRegistrations:
    case FilterGroup.lessRegistrations:
      return l10n.registrations;
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
    case FilterGroup.ageGroup:
      String groupType = filterName.split(':').first;
      String age = filterName.split(':').last;
      return l10n.ageGroupAbbreviated(groupType) + age;
    case FilterGroup.playingLevel:
      return filterName;
    case FilterGroup.competitionType:
      return l10n.competitionType(filterName);
    case FilterGroup.genderCategory:
      return l10n.genderCategory(filterName);
    case FilterGroup.playerStatus:
      return l10n.playerStatus(filterName);
    case FilterGroup.playerSearch:
      return '';
    case FilterGroup.moreRegistrations:
      String count = filterName.split(':').last;
      return '$count ${l10n.orMore}';
    case FilterGroup.lessRegistrations:
      String count = filterName.split(':').last;
      return '$count ${l10n.orLess}';
  }
}

String courtName(
  AppLocalizations l10n,
  Gymnasium gymnasium,
  int row,
  int column,
) {
  int courtNumber = row + column * gymnasium.rows + 1;

  return l10n.courtN(courtNumber);
}

String tournamentMode<M extends TournamentModeSettings>(
  AppLocalizations l10n,
) {
  switch (M) {
    case RoundRobinSettings:
      return l10n.roundRobin;
    case SingleEliminationSettings:
      return l10n.singleElimination;
    case GroupKnockoutSettings:
      return l10n.groupKnockout;
    default:
      return 'OTHER';
  }
}

String tournamentModeTooltip<M extends TournamentModeSettings>(
  AppLocalizations l10n,
) {
  switch (M) {
    case RoundRobinSettings:
      return l10n.roundRobinHelp;
    case SingleEliminationSettings:
      return l10n.singleEliminationHelp;
    case GroupKnockoutSettings:
      return l10n.groupKnockoutHelp;
    default:
      return 'OTHER';
  }
}
