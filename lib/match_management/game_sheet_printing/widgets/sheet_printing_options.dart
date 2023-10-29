import 'dart:io';

import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/match_management/game_sheet_printing/cubit/game_sheet_printing_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/game_sheet_printing/view/custom_print_selection_page.dart';
import 'package:ez_badminton_admin_app/widgets/help_tooltip_icon/help_tooltip_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:formz/formz.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

class SheetPrintingOptions extends StatelessWidget {
  const SheetPrintingOptions({super.key});

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
            const _OpenPdfButton(),
            const SizedBox(height: 8),
            const _OpenSaveLocationButton(),
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

class _OpenPdfButton extends StatelessWidget {
  const _OpenPdfButton();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<GameSheetPrintingCubit>();

    return BlocConsumer<GameSheetPrintingCubit, GameSheetPrintingState>(
      listenWhen: (previous, current) =>
          previous.openedFile.value != current.openedFile.value &&
          current.openedFile.value != null,
      listener: (context, state) {
        launchUrl(Uri.file(
          state.openedFile.value!.path,
          windows: Platform.isWindows,
        ));
      },
      builder: (context, state) {
        bool enabled = state.numSheets > 0 &&
            state.formStatus != FormzSubmissionStatus.inProgress;

        return ElevatedButton(
          onPressed: enabled ? cubit.pdfOpened : null,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.formStatus == FormzSubmissionStatus.inProgress)
                  const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(),
                  )
                else
                  const Icon(Icons.open_in_new, size: 20),
                const SizedBox(width: 8),
                Text(l10n.saveAndOpenPdf),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OpenSaveLocationButton extends StatelessWidget {
  const _OpenSaveLocationButton();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<GameSheetPrintingCubit>();

    return BlocListener<GameSheetPrintingCubit, GameSheetPrintingState>(
      listenWhen: (previous, current) =>
          previous.openedDirectory.value != current.openedDirectory.value &&
          current.openedDirectory.value != null,
      listener: (context, state) {
        OpenFile.open(state.openedDirectory.value!.path);
      },
      child: TextButton(
        onPressed: cubit.saveLocationOpened,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder, size: 16),
            const SizedBox(width: 8),
            Text(l10n.openSaveLocation, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
