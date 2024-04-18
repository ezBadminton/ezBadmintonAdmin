import 'package:collection_repository/collection_repository.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:tournament_mode/tournament_mode.dart';

class ParticipantLabel extends pw.StatelessWidget {
  ParticipantLabel({
    required this.participant,
    this.textStyle,
  });

  final MatchParticipant<Team> participant;

  final pw.TextStyle? textStyle;

  @override
  pw.Widget build(pw.Context context) {
    Team? team = participant.player;

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
    pw.TextStyle textStyle = this.textStyle ?? pw.TextStyle.defaultStyle();

    double lastNameFontSize =
        textStyle.fontSize == null ? 12 : textStyle.fontSize! + 1.5;

    return pw.RichText(
      overflow: pw.TextOverflow.clip,
      text: pw.TextSpan(
        style: textStyle,
        children: [
          pw.TextSpan(
            text: player.firstName,
          ),
          const pw.TextSpan(text: ' '),
          pw.TextSpan(
            text: player.lastName,
            style: textStyle.copyWith(
              fontSize: lastNameFontSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
