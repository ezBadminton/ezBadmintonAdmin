import 'package:collection_repository/collection_repository.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

class CompetitionLabel extends pw.StatelessWidget {
  CompetitionLabel({
    required this.competition,
    required this.l10n,
    this.textStyle,
  });

  final Competition competition;
  final AppLocalizations l10n;

  final pw.TextStyle? textStyle;

  @override
  pw.Widget build(pw.Context context) {
    divider() => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 7),
          child: pw.Text(
            '●',
            style: pw.TextStyle(
              fontSize: 5,
              color: PdfColor.fromHex('#7F7F7F'),
            ),
          ),
        );

    pw.TextStyle textStyle = this.textStyle ?? const pw.TextStyle();

    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        if (competition.playingLevel != null) ...[
          pw.ConstrainedBox(
            constraints: const pw.BoxConstraints(maxWidth: 140),
            child: pw.Text(
              competition.playingLevel!.name,
              overflow: pw.TextOverflow.clip,
              softWrap: false,
              style: textStyle,
            ),
          ),
          divider(),
        ],
        if (competition.ageGroup != null) ...[
          pw.ConstrainedBox(
            constraints: const pw.BoxConstraints(maxWidth: 80),
            child: pw.Text(
              display_strings.ageGroup(
                l10n,
                competition.ageGroup!,
              ),
              overflow: pw.TextOverflow.clip,
              softWrap: false,
              style: textStyle,
            ),
          ),
          divider(),
        ],
        pw.Text(
          display_strings.competitionGenderAndType(
            l10n,
            competition.genderCategory,
            competition.type,
          ),
          style: textStyle.copyWith(fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }
}
