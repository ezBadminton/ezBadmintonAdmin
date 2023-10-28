import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/participant_label.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:tournament_mode/tournament_mode.dart';

class Scoreboard extends pw.StatelessWidget {
  Scoreboard({
    required this.match,
  });

  final BadmintonMatch match;

  @override
  pw.Widget build(pw.Context context) {
    int maxSets = 2 * match.competition.tournamentModeSettings!.winningSets - 1;

    return pw.Column(
      children: [
        pw.Divider(
          height: 0,
          indent: 0.1,
          endIndent: 0.1,
        ),
        _buildScoreLine(match.a, maxSets),
        pw.Divider(
          height: 0,
          indent: 0.1,
          endIndent: 0.1,
        ),
        _buildScoreLine(match.b, maxSets),
      ],
    );
  }

  pw.Widget _buildScoreLine(MatchParticipant<Team> participant, int maxSets) {
    return pw.SizedBox(
      height: 42,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Expanded(
            child: ParticipantLabel(participant: participant),
          ),
          pw.SizedBox(width: 3),
          for (int i = 0; i < maxSets; i += 1)
            pw.Container(
              width: 37,
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
