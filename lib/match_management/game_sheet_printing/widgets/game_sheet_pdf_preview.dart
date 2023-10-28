import 'dart:typed_data';

import 'package:ez_badminton_admin_app/match_management/game_sheet_printing/cubit/game_sheet_printing_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GameSheetPdfPreview extends StatelessWidget {
  const GameSheetPdfPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameSheetPrintingCubit, GameSheetPrintingState>(
      builder: (context, state) {
        if (state.numSheets == 0) {
          var l10n = AppLocalizations.of(context)!;
          return Text(
            l10n.noSheetsToPrint,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(.25),
              fontSize: 21,
            ),
            textAlign: TextAlign.center,
          );
        }

        pw.Document? pdfDoc = state.gameSheetPdf.value;

        Future<Uint8List> pdfBytes =
            pdfDoc != null ? pdfDoc.save() : pw.Document().save();

        return PdfPreview(
          allowPrinting: false,
          allowSharing: false,
          canChangeOrientation: false,
          canChangePageFormat: false,
          build: (format) => pdfBytes,
        );
      },
    );
  }
}
