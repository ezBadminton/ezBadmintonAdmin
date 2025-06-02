import 'package:ez_badminton_admin_app/printing/pdf_widgets/slot_label.dart';
import 'package:model_repository/model_repository.dart';
import 'package:pdf/widgets.dart' as pw;

class Scoreboard extends pw.StatelessWidget {
  Scoreboard({
    required this.competition,
    required this.match,
    this.height = 84,
    this.scoreFieldWidth = 37,
    this.textStyle,
    this.placeholders = const {},
    this.byePlaceholder,
  });

  final Competition? competition;
  final TournamentMatch? match;

  final double height;
  final double scoreFieldWidth;

  final pw.TextStyle? textStyle;

  final Map<Slot, pw.Widget> placeholders;

  final pw.Widget? byePlaceholder;

  @override
  pw.Widget build(pw.Context context) {
    int winningSets = competition == null
        ? 2
        : competition!.tournamentModeSettings!.winningSets;
    int maxSets = 2 * winningSets - 1;

    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        _buildScoreLine(match?.slot1, maxSets),
        pw.Divider(
          height: 0,
          indent: 0.1,
          endIndent: 0.1,
        ),
        _buildScoreLine(match?.slot2, maxSets),
      ],
    );
  }

  pw.Widget _buildScoreLine(Slot? slot, int maxSets) {
    int slotIndex = slot == match?.slot1 ? 0 : 1;
    List<pw.Widget> scoreNumbers = [];

    for (var set in match?.sets ?? []) {
      int score = slotIndex == 0 ? set.team1Points : set.team2Points;
      scoreNumbers.add(pw.Text(score.toString()));
    }

    pw.Widget slotLabel = slot == null
        ? pw.SizedBox(height: 10)
        : SlotLabel(
            slot: slot,
            textStyle: textStyle,
            placeholder: placeholders[slot],
            byePlaceholder: byePlaceholder,
          );

    return pw.SizedBox(
      height: height / 2,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Expanded(
            child: slotLabel,
          ),
          pw.SizedBox(width: 3),
          for (int i = 0; i < maxSets; i += 1)
            pw.Container(
              width: scoreFieldWidth,
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  left: pw.BorderSide(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
