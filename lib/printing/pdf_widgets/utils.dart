import 'package:pdf/pdf.dart';
import 'package:tournament_mode/tournament_mode.dart';
import 'package:pdf/widgets.dart' as pw;

Map<MatchParticipant, pw.Widget> wrapPlaceholderLabels(
  Map<MatchParticipant, String> labels,
) {
  pw.TextStyle labelTextStyle = const pw.TextStyle(
    fontSize: 9,
    color: PdfColors.grey300,
  );

  Map<MatchParticipant, pw.Widget> placeholders =
      labels.map((participant, text) {
    pw.Widget label = pw.Text(text, style: labelTextStyle);

    return MapEntry(participant, label);
  });

  return placeholders;
}
