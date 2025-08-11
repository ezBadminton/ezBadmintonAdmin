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
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                l10n.globalCompetitionFilterHint,
                style: const TextStyle(fontSize: 22),
              ),
              const Divider(height: 25, indent: 20, endIndent: 20),
              BlocBuilder<LocalPreferencesCubit, LocalPreferencesState>(
                builder: (context, state) {
                  final value = state.showGlobalCompetitionFilterNotification;
                  return CheckboxListTile(
                    value: value,
                    onChanged: (_) => preferencesCubit
                        .competitionFilterNotificationPreferenceChanged(!value),
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
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
