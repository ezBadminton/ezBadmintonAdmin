import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/tournament_mode_assignment_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/long_tooltip/long_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

class TournametModeSelector extends StatelessWidget {
  const TournametModeSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<TournamentModeAssignmentCubit>();
    return BlocBuilder<TournamentModeAssignmentCubit,
        TournamentModeAssignmentState>(
      builder: (context, state) {
        return Row(
          children: [
            Text(
              l10n.tournamentMode,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButton(
                isExpanded: true,
                onChanged: cubit.tournamentModeChanged,
                value: state.modeType.value,
                hint: Text(l10n.pleaseChoose),
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                items: [
                  _TournamentModeMenuItem<RoundRobinSettings>(),
                  _TournamentModeMenuItem<SingleEliminationSettings>(),
                  _TournamentModeMenuItem<GroupKnockoutSettings>(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TournamentModeMenuItem<M extends TournamentModeSettings>
    extends DropdownMenuItem<Type> {
  _TournamentModeMenuItem({
    super.key,
  }) : super(
          value: M,
          child: _TournamentModeMenuLabel<M>(),
        );
}

class _TournamentModeMenuLabel<M extends TournamentModeSettings>
    extends StatelessWidget {
  const _TournamentModeMenuLabel();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: Text(display_strings.tournamentMode<M>(l10n)),
        ),
        LongTooltip(
          message: display_strings.tournamentModeTooltip<M>(l10n),
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
