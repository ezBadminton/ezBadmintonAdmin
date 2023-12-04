import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/match_management/result_entering/cubit/result_entering_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/result_entering/input_validation/score_input_controller.dart';
import 'package:ez_badminton_admin_app/match_management/result_entering/input_validation/score_input_formatter.dart';
import 'package:ez_badminton_admin_app/widgets/competition_label/competition_label.dart';
import 'package:ez_badminton_admin_app/widgets/help_tooltip_icon/help_tooltip_icon.dart';
import 'package:ez_badminton_admin_app/widgets/match_info/match_info.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/match_participant_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:formz/formz.dart';
import 'package:tournament_mode/tournament_mode.dart';

class ResultInputDialog extends StatelessWidget {
  const ResultInputDialog({
    super.key,
    required this.match,
  });

  final BadmintonMatch match;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    TournamentModeSettings modeSettings =
        match.competition.tournamentModeSettings!;

    bool alreadyHasScore = match.score?.isNotEmpty ?? false;

    String dialogTitle = alreadyHasScore ? l10n.editResult : l10n.enterResult;

    return BlocProvider(
      create: (context) => ResultEnteringCubit(
        match: match,
        matchDataRepository: context.read<CollectionRepository<MatchData>>(),
        matchSetRepository: context.read<CollectionRepository<MatchSet>>(),
        winningPoints: modeSettings.winningPoints,
        winningSets: modeSettings.winningSets,
        twoPointMargin: modeSettings.twoPointMargin,
        maxPoints: modeSettings.maxPoints,
      ),
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
            actionsPadding: const EdgeInsets.fromLTRB(0, 20, 25, 25),
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
                CompetitionLabel(competition: match.competition),
                const SizedBox(height: 8),
                RunningMatchInfo(
                  match: match,
                  textStyle: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                _ResultInputForm(match: match),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                focusNode: cubit.submitButtonFocusNode,
                onPressed: state.winningParticipantIndex == null
                    ? null
                    : cubit.resultSubmitted,
                child: Text(l10n.enterResult),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ResultInputForm extends StatelessWidget {
  const _ResultInputForm({
    required this.match,
  });

  final BadmintonMatch match;

  @override
  Widget build(BuildContext context) {
    var resultEnteringCubit = context.read<ResultEnteringCubit>();

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
              child: _ParticipantScoreInputs(
                match: match,
                participant: match.a,
                inputControllers: resultEnteringCubit.controllers,
              ),
            ),
            Divider(
              height: 1,
              color: borderColor,
            ),
            Expanded(
              child: _ParticipantScoreInputs(
                match: match,
                participant: match.b,
                inputControllers: resultEnteringCubit.controllers,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticipantScoreInputs extends StatelessWidget {
  const _ParticipantScoreInputs({
    required this.match,
    required this.participant,
    required this.inputControllers,
  });

  final BadmintonMatch match;
  final MatchParticipant<Team> participant;

  final List<ScoreInputController> inputControllers;

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<ResultEnteringCubit>();

    Color borderColor = Theme.of(context).colorScheme.onSurface.withOpacity(.6);

    double participantIndex = match.a == participant ? 0 : 1;

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
            _MatchParticipantLabel(
              participant: participant,
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

class _MatchParticipantLabel extends StatelessWidget {
  const _MatchParticipantLabel({
    required this.participant,
    required this.markAsWinner,
  });

  final MatchParticipant<Team> participant;

  final bool markAsWinner;

  @override
  Widget build(BuildContext context) {
    return MatchParticipantLabel(
      participant,
      teamSize: participant.resolvePlayer()!.players.length,
      isEditable: false,
      alignment: CrossAxisAlignment.end,
      textStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 20,
        fontWeight: markAsWinner ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
