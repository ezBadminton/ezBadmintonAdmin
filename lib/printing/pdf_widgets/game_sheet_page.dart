import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/game_sheet.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GameSheetPage extends pw.StatelessWidget {
  GameSheetPage({
    required this.matches,
    required this.l10n,
    double sheetSpacing = 0.33,
  }) : sheetSpacing = sheetSpacing * PdfPageFormat.cm;

  final List<BadmintonMatch> matches;
  final AppLocalizations l10n;

  final double sheetSpacing;

  @override
  pw.Widget build(pw.Context context) {
    List<pw.Widget> sheets = matches
        .map(
          (m) => GameSheet(
            match: m,
            l10n: l10n,
            padding: sheetSpacing * 0.5,
          ),
        )
        .toList();

    return pw.Wrap(children: sheets);
  }
}
