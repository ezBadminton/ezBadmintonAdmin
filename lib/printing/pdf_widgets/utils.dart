import 'package:model_repository/model_repository.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Map<Slot, pw.Widget> wrapPlaceholderLabels(
  Map<Slot, String> labels,
) {
  pw.TextStyle labelTextStyle = const pw.TextStyle(
    fontSize: 9,
    color: PdfColors.grey300,
  );

  Map<Slot, pw.Widget> placeholders = labels.map((participant, text) {
    pw.Widget label = pw.Text(text, style: labelTextStyle);

    return MapEntry(participant, label);
  });

  return placeholders;
}
