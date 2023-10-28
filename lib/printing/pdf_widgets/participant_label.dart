import 'package:collection_repository/collection_repository.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:tournament_mode/tournament_mode.dart';

class ParticipantLabel extends pw.StatelessWidget {
  ParticipantLabel({
    required this.participant,
  });

  final MatchParticipant<Team> participant;

  @override
  pw.Widget build(pw.Context context) {
    Team? team = participant.resolvePlayer();

    if (team == null) {
      return pw.SizedBox();
    }

    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        for (Player p in team.players) _buildPlayerName(p),
      ],
    );
  }

  pw.RichText _buildPlayerName(Player player) {
    return pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: player.firstName,
          ),
          const pw.TextSpan(text: ' '),
          pw.TextSpan(
            text: player.lastName,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
