import 'package:ez_badminton_admin_app/printing/pdf_widgets/match_info.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/model_id_qr_code.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/scoreboard.dart';
import 'package:model_repository/model_repository.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GameSheet extends pw.StatelessWidget {
  GameSheet({
    required this.tPlan,
    required this.match,
    required this.l10n,
    required this.padding,
    required this.qrCodeEnabled,
  });

  final TournamentPlan? tPlan;
  final TournamentMatch? match;
  final AppLocalizations l10n;

  final double padding;

  final bool qrCodeEnabled;

  @override
  pw.Widget build(pw.Context context) {
    pw.Widget matchInfo = tPlan == null
        ? pw.SizedBox(height: 61.1)
        : MatchInfo(
            tPlan: tPlan!,
            match: match!,
            l10n: l10n,
          );

    return pw.LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints!.maxWidth * 0.5;
        pw.EdgeInsets edgeInsets = pw.EdgeInsets.all(padding);

        return pw.Padding(
          padding: edgeInsets,
          child: pw.Container(
            width: width - edgeInsets.horizontal,
            decoration: pw.BoxDecoration(border: pw.TableBorder.all()),
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: matchInfo,
                      ),
                      if (qrCodeEnabled && match != null) ModelIdQRCode(match!),
                    ],
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Divider(
                  height: 0,
                  indent: 0.1,
                  endIndent: 0.1,
                ),
                Scoreboard(competition: tPlan?.competition, match: match),
              ],
            ),
          ),
        );
      },
    );
  }
}
