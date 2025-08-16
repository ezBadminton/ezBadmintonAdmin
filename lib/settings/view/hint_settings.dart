import 'package:ez_badminton_admin_app/l10n/l10n.dart';
import 'package:ez_badminton_admin_app/settings/cubit/local_preferences_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HintSettingsPage extends StatelessWidget {
  const HintSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    final LocalPreferencesCubit preferencesCubit = BlocProvider.of(context);

    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 600,
          child: BlocBuilder<LocalPreferencesCubit, LocalPreferencesState>(
            builder: (context, state) {
              return Column(
                children: [
                  const SizedBox(height: 40),
                  Text(
                    l10n.hintSettings,
                    style: const TextStyle(fontSize: 22),
                  ),
                  const Divider(height: 25, indent: 20, endIndent: 20),
                  CheckboxListTile(
                    value: state.showGlobalCompetitionFilterNotification,
                    onChanged: (_) => preferencesCubit
                        .competitionFilterNotificationPreferenceChanged(
                      !state.showGlobalCompetitionFilterNotification,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    title: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '“ ',
                            style: TextStyle(fontSize: 23),
                          ),
                          TextSpan(
                            text: l10n.globalCompetitionFilterActive,
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                          TextSpan(
                            text: ' ”',
                            style: TextStyle(fontSize: 23),
                          ),
                        ],
                        style: DefaultTextStyle.of(context).style,
                      ),
                    ),
                    subtitle: Text(l10n.showHint),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: state.showQualificationOverrideNotification,
                    onChanged: (_) => preferencesCubit
                        .qualificatinoOverrideNotificationPreferenceChanged(
                      !state.showQualificationOverrideNotification,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    title: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '“ ',
                            style: TextStyle(fontSize: 23),
                          ),
                          TextSpan(
                            text: l10n.qualificationOverrideAvailable,
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                          TextSpan(
                            text: ' ”',
                            style: TextStyle(fontSize: 23),
                          ),
                        ],
                        style: DefaultTextStyle.of(context).style,
                      ),
                    ),
                    subtitle: Text(l10n.showHint),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
