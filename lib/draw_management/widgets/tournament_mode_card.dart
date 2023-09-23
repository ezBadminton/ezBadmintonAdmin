import 'package:collection_repository/collection_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

/// A card containing the name and a list of all settings of a tournament mode.
class TournamentModeCard extends StatelessWidget {
  const TournamentModeCard({
    super.key,
    required this.modeSettings,
    this.child,
  });

  final TournamentModeSettings modeSettings;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    String modeName = display_strings.tournamentMode(l10n, modeSettings);

    List<String> modeSettingStrings =
        display_strings.tournamentModeSettingsList(l10n, modeSettings);

    return Card(
      elevation: 5.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              modeName,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            for (String modeSetting in modeSettingStrings)
              Text(
                modeSetting,
                style: const TextStyle(fontSize: 16),
              ),
            if (child != null) ...[
              const SizedBox(height: 30),
              child!,
            ],
          ],
        ),
      ),
    );
  }
}
