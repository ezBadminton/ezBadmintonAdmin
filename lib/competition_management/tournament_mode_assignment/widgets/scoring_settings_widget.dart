import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/tournament_mode_assignment_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/tournament_mode_settings_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/tournament_mode_settings_state.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/input_models/tournament_mode_settings_input.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/widgets/setting_card.dart';
import 'package:ez_badminton_admin_app/widgets/integer_stepper/integer_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:formz/formz.dart';

class ScoringSettingsWidget<C extends TournamentModeSettingsCubit<S>,
    S extends TournamentModeSettings> extends StatelessWidget {
  const ScoringSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    var settingsCubit = context.read<C>();

    return BlocBuilder<C, TournamentModeSettingsState<S>>(
      builder: (context, settingsState) => BlocBuilder<
          TournamentModeAssignmentCubit, TournamentModeAssignmentState>(
        builder: (context, assignmentState) {
          SettingsValidationError? validationError;

          if (assignmentState.formStatus == FormzSubmissionStatus.failure) {
            validationError = assignmentState.modeSettings
                .validator(assignmentState.modeSettings.value);
          }

          return Column(
            children: [
              const SizedBox(height: 50),
              Text(l10n.playMode, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              const Divider(
                height: 1,
                indent: 20,
                endIndent: 20,
                thickness: 0,
              ),
              const SizedBox(height: 20),
              _ScoreSettingInput(
                title: Text(l10n.winningPoints),
                helpText: l10n.winningPointsHelp,
                initalValue: settingsState.settings.winningPoints,
                onChanged: settingsCubit.winningPointsChanged,
                maxLength: 2,
                errorText: validationError ==
                        SettingsValidationError.winningPointsEmpty
                    ? l10n.pleaseFillIn
                    : null,
              ),
              SettingCard(
                title: Text(l10n.winningSets),
                helpText: l10n.winningSetsHelp(
                  settingsState.settings.winningSets,
                  2 * settingsState.settings.winningSets - 1,
                ),
                child: IntegerStepper(
                  initialValue: settingsState.settings.winningSets,
                  onChanged: settingsCubit.winningSetsChanged,
                  minValue: 1,
                  maxValue: 9,
                ),
              ),
              SettingCard(
                title: Text(l10n.twoPointMargin),
                helpText: l10n.twoPointMarginHelp,
                child: Switch(
                  value: settingsState.settings.twoPointMargin,
                  onChanged: settingsCubit.twoPointMarginChanged,
                ),
              ),
              if (settingsState.settings.twoPointMargin)
                _ScoreSettingInput(
                  title: Text(l10n.maxPoints),
                  helpText: l10n.maxPointsHelp,
                  initalValue: settingsState.settings.maxPoints,
                  onChanged: settingsCubit.maxPointsChanged,
                  maxLength: 2,
                  errorText: validationError ==
                          SettingsValidationError.maxPointsIncompatible
                      ? l10n.maxPointsError
                      : null,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ScoreSettingInput extends StatelessWidget {
  const _ScoreSettingInput({
    required this.title,
    required this.helpText,
    this.errorText,
    required this.initalValue,
    required this.onChanged,
    required this.maxLength,
  });

  final Widget title;

  final String helpText;

  final String? errorText;

  final int initalValue;

  final void Function(int value) onChanged;

  final int maxLength;

  @override
  Widget build(BuildContext context) {
    return SettingCard(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          if (errorText != null)
            Text(
              errorText!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
      helpText: helpText,
      child: SizedBox(
        width: 50,
        child: TextFormField(
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
          initialValue: '$initalValue',
          onChanged: (value) {
            int parsedValue = value.isEmpty ? 0 : int.parse(value);
            onChanged(parsedValue);
          },
          inputFormatters: [
            LengthLimitingTextInputFormatter(maxLength),
            FilteringTextInputFormatter.digitsOnly,
            _ScoreSettingInputFormatter(),
          ],
        ),
      ),
    );
  }
}

class _ScoreSettingInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    int? number = int.tryParse(newValue.text);

    if (number == 0) {
      return oldValue;
    }

    return newValue;
  }
}
