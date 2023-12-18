import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/tournament_mode_assignment_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/widgets/group_knockout_settings_widget.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/widgets/round_robin_settings_widget.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/widgets/basic_settings_widget.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/widgets/tournament_mode_selector.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/dialog_listener.dart';
import 'package:ez_badminton_admin_app/widgets/dialogs/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TournamentModeSettingsWidget extends StatelessWidget {
  const TournamentModeSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BlocBuilder<TournamentModeAssignmentCubit,
        TournamentModeAssignmentState>(
      builder: (context, state) {
        Widget modeSettingsWidget = switch (state.modeType.value) {
          RoundRobinSettings => const RoundRobinSettingsWidget(),
          SingleEliminationSettings =>
            const BasicSettingsWidget<SingleEliminationSettings>(),
          GroupKnockoutSettings => const GroupKnockoutSettingsWidget(),
          DoubleEliminationSettings =>
            const BasicSettingsWidget<DoubleEliminationSettings>(),
          null => const SizedBox(),
          _ => throw Exception('No settings widget for this mode!'),
        };

        return DialogListener<TournamentModeAssignmentCubit,
            TournamentModeAssignmentState, bool>(
          builder: (context, state, reason) => ConfirmDialog(
            title: Text(l10n.drawsWillBeOverridden),
            content: Text(l10n.drawsWillBeOverriddenInfo),
            confirmButtonLabel: l10n.confirm,
            cancelButtonLabel: l10n.cancel,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 600,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    const TournametModeSelector(),
                    const SizedBox(height: 20),
                    const Divider(
                      height: 1,
                      indent: 20,
                      endIndent: 20,
                      thickness: 0,
                    ),
                    const SizedBox(height: 30),
                    modeSettingsWidget,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
