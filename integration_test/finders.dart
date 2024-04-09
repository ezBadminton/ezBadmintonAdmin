import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/view/registration_display_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

Finder findRegistrationCard(
  AppLocalizations l10n,
  String firstName,
  String lastName,
  String? playingLevel,
  String? ageGroup,
  String genderCategory,
  String competitionType,
  String? partner,
) {
  Finder registrationCardFinder = find.byWidgetPredicate((widget) {
    if (widget is! RegistrationDisplayCard) {
      return false;
    }
    Competition competition = widget.competition;
    Player player = widget.registration.player;
    String playerName = '${player.firstName} ${player.lastName}';

    bool equalPlayer = playerName == '$firstName $lastName';

    bool equalPlayingLevel = competition.playingLevel?.name == playingLevel;
    String? competitionAgeGroup = competition.ageGroup == null
        ? null
        : display_strings.ageGroup(l10n, competition.ageGroup!);
    bool equalAgeGroup = competitionAgeGroup == ageGroup;

    bool equalGenderCategory =
        l10n.genderCategory(competition.genderCategory.toString()) ==
            genderCategory;

    bool equalCompetitionType =
        l10n.competitionType(competition.type.toString()) == competitionType;

    Player? registrationParter = widget.registration.partner;
    String? partnerName = registrationParter == null
        ? null
        : '${registrationParter.firstName} ${registrationParter.lastName}';

    bool equalPartner = partnerName == partner;

    return equalPlayer &&
        equalPlayingLevel &&
        equalAgeGroup &&
        equalGenderCategory &&
        equalCompetitionType &&
        equalPartner;
  });

  return registrationCardFinder;
}
