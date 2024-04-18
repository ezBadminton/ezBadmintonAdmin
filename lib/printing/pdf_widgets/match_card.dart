import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/pdf_widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class MatchCard extends pw.StatelessWidget {
  MatchCard({
    required this.match,
  });

  final BadmintonMatch match;

  bool get _isDoubles => match.competition.teamSize == 2;
  int get _maxSets =>
      match.competition.tournamentModeSettings!.winningSets * 2 - 1;

  @override
  pw.Widget build(pw.Context context) {
    PdfPoint size = _getCardSize();

    pw.Widget scoreboard = Scoreboard(
      match: match,
      height: size.y,
      scoreFieldWidth: scoreFieldWidth,
      textStyle: const pw.TextStyle(fontSize: 9),
    );

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: matchCardMargin),
      child: pw.Container(
        width: size.x,
        decoration: const pw.BoxDecoration(
          borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
          border: pw.Border(
            bottom: pw.BorderSide(),
            left: pw.BorderSide(),
            right: pw.BorderSide(),
            top: pw.BorderSide(),
          ),
        ),
        child: scoreboard,
      ),
    );
  }

  PdfPoint _getCardSize() {
    double width = matchCardNameWidth + _maxSets * scoreFieldWidth;
    double height =
        _isDoubles ? matchCardDoublesHeight : matchCardSinglesHeight;

    return PdfPoint(width, height);
  }

  PdfPoint getCardSize() {
    PdfPoint size = _getCardSize().translate(0, 2 * matchCardMargin);

    return size;
  }
}
