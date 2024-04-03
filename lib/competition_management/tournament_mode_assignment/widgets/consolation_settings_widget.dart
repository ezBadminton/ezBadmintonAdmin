import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/consolation_settings_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/tournament_mode_assignment_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/tournament_mode_settings_state.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/input_models/tournament_mode_settings_input.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/widgets/consolation_settings_handler.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/widgets/scoring_settings_widget.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/widgets/seeding_mode_selector.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/widgets/setting_card.dart';
import 'package:ez_badminton_admin_app/widgets/integer_stepper/integer_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:formz/formz.dart';

class ConsolationSettingsWidget extends StatelessWidget {
  const ConsolationSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var assignmentCubit = context.read<TournamentModeAssignmentCubit>();

    return BlocProvider(
      create: (context) => ConsolationSettingsCubit(
        TournamentModeSettingsState(
          settings: assignmentCubit.state.modeSettings.value
              as SingleEliminationWithConsolationSettings,
        ),
      ),
      child: BlocListener<
          ConsolationSettingsCubit,
          TournamentModeSettingsState<
              SingleEliminationWithConsolationSettings>>(
        listener: (context, state) {
          assignmentCubit.tournamentModeSettingsChanged(state.settings);
        },
        child: const Column(
          children: [
            NumConsolationRoundsStepper<ConsolationSettingsCubit>(),
            PlacesToPlayOutInput<ConsolationSettingsCubit>(),
            _SeedingModeSelector(),
            ScoringSettingsWidget<ConsolationSettingsCubit,
                SingleEliminationWithConsolationSettings>(),
          ],
        ),
      ),
    );
  }
}

class NumConsolationRoundsStepper<C extends ConsolationSettingsHandler>
    extends StatelessWidget {
  const NumConsolationRoundsStepper({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var settingsCubit = context.read<C>();

    return BlocBuilder<C, TournamentModeSettingsState>(
      builder: (context, state) {
        int numConsolationRounds = switch (state.settings) {
          SingleEliminationWithConsolationSettings s => s.numConsolationRounds,
          GroupKnockoutSettings s => s.numConsolationRounds,
          _ => throw Exception(
              "This TournamentModeSettingsCubit cannot process consolation elimination settings.",
            ),
        };

        return SettingCard(
          title: Text(l10n.numConsolationRounds),
          helpText: l10n.numConsolationRoundsHelp(
            '$numConsolationRounds ${l10n.match(numConsolationRounds)}',
          ),
          child: IntegerStepper(
            initialValue: numConsolationRounds,
            onChanged: settingsCubit.numConsolationRoundsChanged,
          ),
        );
      },
    );
  }
}

class PlacesToPlayOutInput<C extends ConsolationSettingsHandler>
    extends StatelessWidget {
  const PlacesToPlayOutInput({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var settingsCubit = context.read<C>();

    return BlocBuilder<C, TournamentModeSettingsState>(
      builder: (context, state) {
        int placesToPlayOut = switch (state.settings) {
          SingleEliminationWithConsolationSettings s => s.placesToPlayOut,
          GroupKnockoutSettings s => s.placesToPlayOut,
          _ => throw Exception(
              "This TournamentModeSettingsCubit cannot process consolation elimination settings.",
            ),
        };

        return SettingCard(
          title: BlocBuilder<TournamentModeAssignmentCubit,
              TournamentModeAssignmentState>(
            builder: (context, assignmentState) {
              SettingsValidationError? validationError;

              if (assignmentState.formStatus == FormzSubmissionStatus.failure) {
                validationError = assignmentState.modeSettings
                    .validator(assignmentState.modeSettings.value);
              }

              String? errorText;
              if (validationError ==
                  SettingsValidationError.tooFewPlacesToPlayOut) {
                errorText = l10n.tooFewPlacesToPlayOut;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.placesToPlayOut),
                  if (errorText != null)
                    Text(
                      errorText,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                ],
              );
            },
          ),
          helpText: l10n.placesToPlayOutHelp('$placesToPlayOut'),
          child: SizedBox(
            width: 50,
            child: TextFormField(
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
              initialValue: '$placesToPlayOut',
              onChanged: (value) {
                int parsedValue = value.isEmpty ? 0 : int.parse(value);
                settingsCubit.placesToPlayOutChanged(parsedValue);
              },
              inputFormatters: [
                LengthLimitingTextInputFormatter(2),
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SeedingModeSelector extends StatelessWidget {
  const _SeedingModeSelector();

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<ConsolationSettingsCubit>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 25.0),
        child: SeedingModeSelector(
          onChanged: cubit.seedingModeChanged,
        ),
      ),
    );
  }
}
