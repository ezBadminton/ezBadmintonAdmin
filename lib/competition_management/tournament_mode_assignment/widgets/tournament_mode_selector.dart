import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/tournament_mode_assignment_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tooltip_dropdown_menu_item/tooltip_dropdown_menu_item.dart';
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
                  _TournamentModeMenuItem<RoundRobinSettings>(l10n),
                  _TournamentModeMenuItem<SingleEliminationSettings>(l10n),
                  _TournamentModeMenuItem<GroupKnockoutSettings>(l10n),
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
    extends TooltipDropdownMenuItem<Type> {
  _TournamentModeMenuItem(AppLocalizations l10n)
      : super(
          value: M,
          label: display_strings.tournamentMode<M>(l10n),
          helpText: display_strings.tournamentModeTooltip<M>(l10n),
        );
}
