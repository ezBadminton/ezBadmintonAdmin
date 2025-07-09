import 'package:ez_badminton_admin_app/widgets/tournament_context/tournament_context.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/match_management/result_entering/cubit/result_deletion_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/result_entering/cubit/result_entering_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/result_entering/input_validation/score_input_controller.dart';
import 'package:ez_badminton_admin_app/match_management/result_entering/input_validation/score_input_formatter.dart';
import 'package:ez_badminton_admin_app/widgets/competition_label/competition_label.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/dialog_listener.dart';
import 'package:ez_badminton_admin_app/widgets/dialogs/confirm_dialog.dart';
import 'package:ez_badminton_admin_app/widgets/help_tooltip_icon/help_tooltip_icon.dart';
import 'package:ez_badminton_admin_app/widgets/match_info/match_info.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/slot_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ez_badminton_admin_app/l10n/l10n.dart';
import 'package:formz/formz.dart';

class ResultInputDialog extends StatelessWidget {
  const ResultInputDialog({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    var tPlan = context.readTournamentPlan();
    var match = context.readMatch();

    TournamentModeSettings modeSettings =
        tPlan.competition.tournamentModeSettings!;

    bool alreadyHasScore = match.sets.isNotEmpty;

    String dialogTitle = alreadyHasScore ? l10n.editResult : l10n.enterResult;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ResultEnteringCubit(
            match: match,
            scoreEndpoint: context.read<SetScoreEndpoint>(),
            winningPoints: modeSettings.winningPoints,
            winningSets: modeSettings.winningSets,
            twoPointMargin: modeSettings.twoPointMargin,
            maxPoints: modeSettings.maxPoints,
          ),
        ),
        BlocProvider(
          create: (context) => ResultDeletionCubit(
            match: match,
            resetEndpoint: context.read<ResetMatchEndpoint>(),
          ),
        ),
      ],
      child: BlocConsumer<ResultEnteringCubit, ResultEnteringState>(
        listenWhen: (previous, current) =>
            previous.formStatus != FormzSubmissionStatus.success &&
            current.formStatus == FormzSubmissionStatus.success,
        listener: (context, state) => Navigator.of(context).pop(),
        buildWhen: (previous, current) =>
            previous.winningParticipantIndex != current.winningParticipantIndex,
        builder: (context, state) {
          var cubit = context.read<ResultEnteringCubit>();

          return AlertDialog(
            actionsPadding: const EdgeInsets.fromLTRB(20, 20, 25, 25),
            title: Row(
              children: [
                Text(dialogTitle),
                const SizedBox(width: 7),
                HelpTooltipIcon(helpText: l10n.resultEnteringHelp),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CompetitionLabel(competition: tPlan.competition),
                const SizedBox(height: 8),
                RunningMatchInfo(
                  textStyle: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                _ResultInputForm(),
              ],
            ),
            actions: [
              Row(
                children: [
                  _ResultDeleteButton(),
                  const Expanded(child: SizedBox()),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton(
                    focusNode: cubit.submitButtonFocusNode,
                    onPressed: state.winningParticipantIndex == null
                        ? null
                        : cubit.resultSubmitted,
                    child: Text(l10n.enterResult),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ResultInputForm extends StatelessWidget {
  const _ResultInputForm();

  @override
  Widget build(BuildContext context) {
    var resultEnteringCubit = context.read<ResultEnteringCubit>();

    var match = context.readMatch();

    Color borderColor = Theme.of(context).colorScheme.onSurface.withOpacity(.6);

    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Container(
        height: 170,
        width: 700,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _ScoreInputs(
                match: match,
                slot: match.slot1,
                inputControllers: resultEnteringCubit.controllers,
              ),
            ),
            Divider(
              height: 1,
              color: borderColor,
            ),
            Expanded(
              child: _ScoreInputs(
                match: match,
                slot: match.slot2,
                inputControllers: resultEnteringCubit.controllers,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreInputs extends StatelessWidget {
  const _ScoreInputs({
    required this.match,
    required this.slot,
    required this.inputControllers,
  });

  final TournamentMatch match;
  final Slot slot;

  final List<ScoreInputController> inputControllers;

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<ResultEnteringCubit>();

    Color borderColor = Theme.of(context).colorScheme.onSurface.withOpacity(.6);

    double participantIndex = match.slot1 == slot ? 0 : 1;

    return BlocBuilder<ResultEnteringCubit, ResultEnteringState>(
      builder: (context, state) {
        List<_ScoreInputField> inputFields = cubit.controllers
            .where((c) => c.participantIndex == participantIndex)
            .map(
              (c) => _ScoreInputField(
                focusOrder: participantIndex + 2 * c.setIndex,
                controller: c,
                markAsWinner:
                    cubit.getSetWinner(cubit.getSetResult(c.setIndex)) ==
                        participantIndex,
              ),
            )
            .toList();

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _SlotLabel(
              slot: slot,
              markAsWinner: participantIndex == state.winningParticipantIndex,
            ),
            for (_ScoreInputField inputField in inputFields) ...[
              VerticalDivider(width: 1, color: borderColor),
              inputField,
            ],
          ],
        );
      },
    );
  }
}

class _ScoreInputField extends StatelessWidget {
  const _ScoreInputField({
    required this.focusOrder,
    required this.controller,
    required this.markAsWinner,
  });

  final double focusOrder;

  final ScoreInputController controller;

  final bool markAsWinner;

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<ResultEnteringCubit>();

    return SizedBox(
      width: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: FocusTraversalOrder(
          order: NumericFocusOrder(focusOrder),
          child: BlocBuilder<ResultEnteringCubit, ResultEnteringState>(
            builder: (context, state) {
              return TextField(
                style: TextStyle(
                  fontSize: 30,
                  fontWeight:
                      markAsWinner ? FontWeight.w600 : FontWeight.normal,
                  color:
                      markAsWinner ? Theme.of(context).primaryColorDark : null,
                ),
                textAlign: TextAlign.center,
                controller: controller.editingController,
                focusNode: controller.focusNode,
                onChanged: (_) => cubit.scoreChanged(controller),
                onSubmitted: (_) => cubit.scoreSubmitted(controller),
                autofocus: controller.setIndex == 0 &&
                    controller.participantIndex == 0,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(2),
                  FilteringTextInputFormatter.digitsOnly,
                  ScoreInputFormatter(maxPoints: cubit.maxPoints),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SlotLabel extends StatelessWidget {
  const _SlotLabel({
    required this.slot,
    required this.markAsWinner,
  });

  final Slot slot;

  final bool markAsWinner;

  @override
  Widget build(BuildContext context) {
    return SlotLabel(
      slot,
      teamSize: slot.team!.players.length,
      alignment: CrossAxisAlignment.end,
      textStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 20,
        fontWeight: markAsWinner ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class _ResultDeleteButton extends StatelessWidget {
  const _ResultDeleteButton();

  @override
  Widget build(BuildContext context) {
    var match = context.readMatch();

    if (match.sets.isEmpty) {
      return const SizedBox();
    }

    var l10n = AppLocalizations.of(context)!;

    var deletionCubit = context.read<ResultDeletionCubit>();

    return DialogListener<ResultDeletionCubit, ResultDeletionState, bool>(
      builder: (context, state, reason) {
        return ConfirmDialog(
          title: Text(l10n.deleteResult),
          content: Text(l10n.deleteResultInfo),
          confirmButtonLabel: l10n.confirm,
          cancelButtonLabel: l10n.cancel,
        );
      },
      child: BlocListener<ResultDeletionCubit, ResultDeletionState>(
        listenWhen: (previous, current) =>
            previous.formStatus != FormzSubmissionStatus.success &&
            current.formStatus == FormzSubmissionStatus.success,
        listener: (context, state) => Navigator.of(context).pop(),
        child: TextButton(
          onPressed: deletionCubit.resultDeleted,
          child: Text(
            l10n.deleteResult,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error.withOpacity(.7),
            ),
          ),
        ),
      ),
    );
  }
}
