import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/utils/gender_categories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

abstract class RegistrationWarning {
  String getWarningMessage(BuildContext context);
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
