import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/match_management/game_sheet_printing/cubit/game_sheet_printing_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/game_sheet_printing/view/custom_print_selection_page.dart';
import 'package:ez_badminton_admin_app/printing/open_pdf_button.dart';
import 'package:ez_badminton_admin_app/widgets/help_tooltip_icon/help_tooltip_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SheetPrintingSelectionWidget extends StatelessWidget {
  const SheetPrintingSelectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    List<PrintSelection> standardSelections = List.of(PrintSelection.values)
      ..remove(PrintSelection.custom);

    return BlocBuilder<GameSheetPrintingCubit, GameSheetPrintingState>(
      builder: (context, state) {
        return Column(
          children: [
            for (PrintSelection printSelection in standardSelections)
              _SelectionOptionRadioTile(
                value: printSelection,
                groupValue: state.printSelection,
              ),
            _SelectionOptionRadioTile(
              value: PrintSelection.custom,
              groupValue: state.printSelection,
              title: _CustomSelectionTitle(
                enabled: state.printSelection == PrintSelection.custom,
              ),
            ),
            const SizedBox(height: 25),
            const OpenPdfButton<GameSheetPrintingCubit,
                GameSheetPrintingState>(),
            const SizedBox(height: 8),
            const OpenPdfSaveLocationButton<GameSheetPrintingCubit,
                GameSheetPrintingState>(),
          ],
        );
      },
    );
  }
}

class _CustomSelectionTitle extends StatelessWidget {
  const _CustomSelectionTitle({
    required this.enabled,
  });

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<GameSheetPrintingCubit>();
    var l10n = AppLocalizations.of(context)!;

    return Row(
      textBaseline: TextBaseline.alphabetic,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      children: [
        Text(
          l10n.gameSheetPrintSelection(PrintSelection.custom.toString()),
        ),
        const SizedBox(width: 10),
        TextButton(
          onPressed: enabled
              ? () async {
                  List<BadmintonMatch>? newSelection =
                      await Navigator.of(context).push(
                    CustomPrintSelectionPage.route(cubit.state.customSelection),
                  );

                  if (newSelection != null) {
                    cubit.customSelectionChanged(newSelection);
                  }
                }
              : null,
          child: Text(l10n.changeSelection),
        ),
      ],
    );
  }
}

class _SelectionOptionRadioTile extends StatelessWidget {
  const _SelectionOptionRadioTile({
    required this.value,
    required this.groupValue,
    this.title,
  });

  final PrintSelection value;
  final PrintSelection groupValue;

  final Widget? title;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var printingCubit = context.read<GameSheetPrintingCubit>();

    return RadioListTile(
      title: title ?? Text(l10n.gameSheetPrintSelection(value.toString())),
      secondary: HelpTooltipIcon(
        helpText: l10n.gameSheetPrintSelectionHelp(
          value.toString(),
        ),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: (value) {
        if (value != null) {
          printingCubit.printSelectionChanged(value);
        }
      },
    );
  }
}
