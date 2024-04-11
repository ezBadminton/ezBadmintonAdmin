import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/display_strings/match_names.dart';
import 'package:ez_badminton_admin_app/competition_management/models/competition_category.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate_producers.dart';
import 'package:ez_badminton_admin_app/utils/powers_of_two.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tournament_mode/tournament_mode.dart';

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

String playerLastNameWithClub(Player player) {
  String name = player.lastName;
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

String competitionLabel(
  AppLocalizations l10n,
  Competition competition,
) {
  StringBuffer label = StringBuffer();

  if (competition.playingLevel != null) {
    label.write('${competition.playingLevel!.name} ● ');
  }
  if (competition.ageGroup != null) {
    label.write('${ageGroup(l10n, competition.ageGroup!)} ● ');
  }
  label.write(competitionCategory(
    l10n,
    CompetitionDiscipline.fromCompetition(competition),
  ));

  return label.toString();
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

String tournamentMode(
  AppLocalizations l10n,
  TournamentModeSettings tournamentModeSettings,
) {
  switch (tournamentModeSettings) {
    case RoundRobinSettings _:
      return tournamentModeFromType(l10n, RoundRobinSettings);
    case SingleEliminationSettings _:
      return tournamentModeFromType(l10n, SingleEliminationSettings);
    case GroupKnockoutSettings _:
      return tournamentModeFromType(l10n, GroupKnockoutSettings);
    case DoubleEliminationSettings _:
      return tournamentModeFromType(l10n, DoubleEliminationSettings);
    case SingleEliminationWithConsolationSettings _:
      return tournamentModeFromType(
        l10n,
        SingleEliminationWithConsolationSettings,
      );
  }
}

String tournamentModeFromType(
  AppLocalizations l10n,
  Type tournamentModeSettings,
) {
  switch (tournamentModeSettings) {
    case RoundRobinSettings:
      return l10n.roundRobin;
    case SingleEliminationSettings:
      return l10n.singleElimination;
    case GroupKnockoutSettings:
      return l10n.groupKnockout;
    case DoubleEliminationSettings:
      return l10n.doubleElimination;
    case SingleEliminationWithConsolationSettings:
      return l10n.consolationElimination;
    default:
      return 'OTHER';
  }
}

String tournamentModeTooltip(
  AppLocalizations l10n,
  Type tournamentModeSettings,
) {
  switch (tournamentModeSettings) {
    case RoundRobinSettings:
      return l10n.roundRobinHelp;
    case SingleEliminationSettings:
      return l10n.singleEliminationHelp;
    case GroupKnockoutSettings:
      return l10n.groupKnockoutHelp;
    case DoubleEliminationSettings:
      return l10n.doubleEliminationHelp;
    case SingleEliminationWithConsolationSettings:
      return l10n.consolationEliminationHelp;
    default:
      return 'OTHER';
  }
}

List<String> tournamentModeSettingsList(
  AppLocalizations l10n,
  TournamentModeSettings modeSettings,
) {
  List<String> settingsStrings = [];
  switch (modeSettings) {
    case RoundRobinSettings(passes: int passes):
      settingsStrings.add('${l10n.passes}: $passes');
      break;
    case SingleEliminationSettings _:
    case DoubleEliminationSettings _:
      break;
    case GroupKnockoutSettings(
        numGroups: int numGroups,
        numQualifications: int numQualifications,
        knockOutMode: KnockOutMode knockOutMode,
        numConsolationRounds: int numConsolationRounds,
        placesToPlayOut: int placesToPlayOut,
      ):
      settingsStrings.add(
        '${l10n.numGroups}: $numGroups',
      );
      settingsStrings.add(
        '${l10n.numQualifications}: $numQualifications',
      );
      settingsStrings.add(
        '${l10n.knockOutMode}: ${knockOutModeName(l10n, knockOutMode)}',
      );
      if (knockOutMode == KnockOutMode.consolation) {
        settingsStrings.add(
          '${l10n.numConsolationRounds}: $numConsolationRounds',
        );
        settingsStrings.add(
          '${l10n.placesToPlayOut}: $placesToPlayOut',
        );
      }
      break;
    case SingleEliminationWithConsolationSettings(
        numConsolationRounds: int numConsolationRounds,
        placesToPlayOut: int placesToPlayOut,
      ):
      settingsStrings.add(
        '${l10n.numConsolationRounds}: $numConsolationRounds',
      );
      settingsStrings.add(
        '${l10n.placesToPlayOut}: $placesToPlayOut',
      );
      break;
  }

  if (modeSettings
      case TournamentModeSettings(
        seedingMode: (SeedingMode seedingMode) && (!= SeedingMode.random),
      )) {
    settingsStrings.add(
      '${l10n.seedingMode}: ${l10n.seedingModeLabel(seedingMode.toString())}',
    );
  }

  return settingsStrings;
}

String seedLabel(int seed, SeedingMode seedingMode) {
  int rank = seed + 1;
  if (rank <= 2 || seedingMode == SeedingMode.single) {
    return '$rank';
  }

  int nextPowOf2 = nextPowerOfTwo(rank);
  if (nextPowOf2 == rank) {
    rank -= 1;
  }
  int prevPowOf2 = previousPowerOfTwo(rank);

  return '${prevPowOf2 + 1}/$nextPowOf2';
}

String? matchName(AppLocalizations l10n, TournamentMatch match) {
  return switch (match.round) {
    GroupPhaseRound<BadmintonMatch> round =>
      round.getGroupMatchName(l10n, match),
    RoundRobinRound round => round.getRoundRobinMatchName(l10n),
    EliminationRound round => round.getEliminationMatchName(l10n, match),
    DoubleEliminationRound round =>
      round.getDoubleEliminationMatchName(l10n, match),
    _ => null,
  };
}

String knockOutModeName(AppLocalizations l10n, KnockOutMode knockOutMode) {
  return switch (knockOutMode) {
    KnockOutMode.single => l10n.singleElimination,
    KnockOutMode.double => l10n.doubleElimination,
    KnockOutMode.consolation => l10n.consolationElimination,
  };
}
