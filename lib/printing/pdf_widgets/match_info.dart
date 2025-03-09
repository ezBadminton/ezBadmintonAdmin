import 'package:ez_badminton_admin_app/printing/pdf_widgets/competition_label.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/writing_line.dart';
import 'package:model_repository/model_repository.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

class MatchInfo extends pw.StatelessWidget {
  MatchInfo({
    required this.tPlan,
    required this.match,
    required this.l10n,
  });

  final TournamentPlan tPlan;
  final TournamentMatch match;
  final AppLocalizations l10n;

  @override
  pw.Widget build(pw.Context context) {
    pw.Widget competitionLabel = CompetitionLabel(
      competition: tPlan.competition,
      l10n: l10n,
    );

    String? roundName = display_strings.matchName(l10n, tPlan, match);
    pw.Widget roundWidget = pw.SizedBox(
      height: 20,
      child: roundName != null ? pw.Text(roundName) : null,
    );

    Court? matchCourt = match.court;
    pw.Widget courtWidget = matchCourt != null
        ? pw.Text(matchCourt.name)
        : WritingLine(label: l10n.court(1), width: 35);

    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        competitionLabel,
        pw.SizedBox(height: 5),
        roundWidget,
        pw.SizedBox(height: 12),
        courtWidget,
      ],
    );
  }
}
