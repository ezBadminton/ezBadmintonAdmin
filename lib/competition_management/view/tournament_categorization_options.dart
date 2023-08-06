import 'package:ez_badminton_admin_app/competition_management/age_group_editing/view/age_group_editing_popup.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_categorization_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_categorization_state.dart';
import 'package:ez_badminton_admin_app/competition_management/playing_level_editing/view/playing_level_editing_popup.dart';
import 'package:ez_badminton_admin_app/widgets/dialogs/confirm_dialog.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/dialog_listener.dart';
import 'package:ez_badminton_admin_app/widgets/custom_input_fields/bloc_switch.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:ez_badminton_admin_app/widgets/long_tooltip/long_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:formz/formz.dart';

class TournamentCategorizationOptions extends StatelessWidget {
  const TournamentCategorizationOptions({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return BlocBuilder<CompetitionCategorizationCubit,
        CompetitionCategorizationState>(
      buildWhen: (previous, current) =>
          previous.loadingStatus != current.loadingStatus,
      builder: (context, state) {
        return LoadingScreen(
          loadingStatus: state.loadingStatus,
          builder: (context) {
            return DialogListener<CompetitionCategorizationCubit,
                CompetitionCategorizationState, bool>(
              builder: (context, _, mergeType) {
                String categorization =
                    switch (mergeType as CategoryMergeType) {
                  CategoryMergeType.ageGroupMerge => l10n.ageGroup(2),
                  CategoryMergeType.playingLevelMerge => l10n.playingLevel(2),
                };
                return ConfirmDialog(
                  title: Text(l10n.disableCategorization(categorization)),
                  content: SizedBox(
                    width: 500,
                    child: Text(l10n.mergeRegistrationsWarning(categorization)),
                  ),
                  confirmButtonLabel: l10n.confirm,
                  cancelButtonLabel: l10n.cancel,
                );
              },
              child: const _CategorizationSwitches(),
            );
          },
        );
      },
    );
  }
}

class _CategorizationSwitches extends StatelessWidget {
  const _CategorizationSwitches();

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<CompetitionCategorizationCubit>();
    var l10n = AppLocalizations.of(context)!;
    return BlocBuilder<CompetitionCategorizationCubit,
        CompetitionCategorizationState>(
      buildWhen: (previous, current) =>
          previous.formStatus != current.formStatus,
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _CategoryPanel(
                valueGetter: (state) => state.tournament.useAgeGroups,
                onChanged: cubit.useAgeGroupsChanged,
                label: l10n.activateAgeGroups,
                helpMessage: l10n.categorizationHint(l10n.ageGroup(2)),
                editButtonLabel: l10n.editSubject(l10n.ageGroup(2)),
                editWidget: const AgeGroupEditingPopup(),
                enabled: state.formStatus != FormzSubmissionStatus.inProgress,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CategoryPanel(
                valueGetter: (state) => state.tournament.usePlayingLevels,
                onChanged: cubit.usePlayingLevelsChanged,
                label: l10n.activatePlayingLevels,
                helpMessage: l10n.categorizationHint(l10n.playingLevel(2)),
                editButtonLabel: l10n.editSubject(l10n.playingLevel(2)),
                editWidget: const PlayingLevelEditingPopup(),
                enabled: state.formStatus != FormzSubmissionStatus.inProgress,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryPanel extends StatelessWidget {
  /// A panel with a switch to toggle playing level/age group categorization
  /// for competitions.
  ///
  /// When the switch is on, an edit button appears to add/remove categories.
  const _CategoryPanel({
    this.enabled = true,
    required this.valueGetter,
    required this.onChanged,
    required this.label,
    required this.helpMessage,
    required this.editButtonLabel,
    required this.editWidget,
  });

  final bool enabled;
  final bool Function(CompetitionCategorizationState) valueGetter;
  final void Function(bool) onChanged;
  // Label next to the switch wigdet
  final String label;
  // Message being shown as a tooltip on a help icon
  final String helpMessage;
  final String editButtonLabel;
  final Widget editWidget;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompetitionCategorizationCubit,
        CompetitionCategorizationState>(
      buildWhen: (previous, current) =>
          valueGetter(previous) != valueGetter(current),
      builder: (context, state) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .background
                .withOpacity(valueGetter(state) ? .5 : .25),
            borderRadius: const BorderRadius.vertical(
              top: Radius.zero,
              bottom: Radius.circular(15),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _CategorySwitchWithHelpIcon(
                label: label,
                valueGetter: valueGetter,
                enabled: enabled,
                onChanged: onChanged,
                helpMessage: helpMessage,
              ),
              TextButton(
                onPressed: () => showDialog(
                  context: context,
                  useRootNavigator: false,
                  builder: (context) => editWidget,
                ),
                child: Text(editButtonLabel),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategorySwitchWithHelpIcon extends StatelessWidget {
  const _CategorySwitchWithHelpIcon({
    required this.label,
    required this.valueGetter,
    required this.enabled,
    required this.onChanged,
    required this.helpMessage,
  });

  final String label;
  final bool Function(CompetitionCategorizationState p1) valueGetter;
  final bool enabled;
  final void Function(bool p1) onChanged;
  final String helpMessage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CategorySwitch(
          label: label,
          valueGetter: valueGetter,
          onChanged: enabled ? onChanged : (_) {},
        ),
        const SizedBox(width: 8),
        LongTooltip(
          message: helpMessage,
          child: Icon(
            Icons.help_outline,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(.5),
            size: 21,
          ),
        ),
      ],
    );
  }
}

class _CategorySwitch extends BlocSwitch<CompetitionCategorizationCubit,
    CompetitionCategorizationState> {
  const _CategorySwitch({
    required super.label,
    required super.valueGetter,
    required super.onChanged,
  });
}
