import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/tournament_mode_assignment_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tooltip_dropdown_menu_item/tooltip_dropdown_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SeedingModeSelector extends StatelessWidget {
  const SeedingModeSelector({
    super.key,
    required this.onChanged,
  });

  final Function(SeedingMode seedingMode) onChanged;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return BlocBuilder<TournamentModeAssignmentCubit,
        TournamentModeAssignmentState>(
      builder: (context, state) {
        return DropdownButtonFormField(
          value: state.modeSettings.value?.seedingMode,
          onChanged: (value) => onChanged(value!),
          decoration: InputDecoration(labelText: l10n.seedingMode),
          isExpanded: true,
          items: [
            TooltipDropdownMenuItem(
              value: SeedingMode.tiered,
              label: l10n.seedingModeLabel(SeedingMode.tiered.toString()),
              helpText: l10n.tieredSeedingHelp,
            ),
            TooltipDropdownMenuItem(
              value: SeedingMode.single,
              label: l10n.seedingModeLabel(SeedingMode.single.toString()),
              helpText: l10n.singleSeedingHelp,
            ),
          ],
        );
      },
    );
  }
}
