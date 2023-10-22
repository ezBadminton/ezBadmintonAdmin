import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/match_participant_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MatchLabel extends StatelessWidget {
  const MatchLabel({
    super.key,
    required this.match,
    this.orientation = Axis.vertical,
    this.participantWidth = 185,
  });

  final BadmintonMatch match;

  final Axis orientation;

  final double participantWidth;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    List<Widget> widgets = [
      MatchParticipantLabel(
        match.a,
        teamSize: match.competition.teamSize,
        isEditable: false,
        width: participantWidth,
        alignment: orientation == Axis.vertical
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.end,
        padding: orientation == Axis.vertical
            ? const EdgeInsets.only(bottom: 8)
            : const EdgeInsets.only(right: 8),
        placeholderLabel: Text(
          l10n.qualificationPending,
          style: TextStyle(color: Theme.of(context).disabledColor),
        ),
        useFullName: false,
      ),
      Text(
        '- ${l10n.versusAbbreviated} -',
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).disabledColor,
        ),
      ),
      MatchParticipantLabel(
        match.b,
        teamSize: match.competition.teamSize,
        isEditable: false,
        width: participantWidth,
        alignment: orientation == Axis.vertical
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        padding: orientation == Axis.vertical
            ? const EdgeInsets.only(top: 8)
            : const EdgeInsets.only(left: 8),
        placeholderLabel: Text(
          l10n.qualificationPending,
          style: TextStyle(color: Theme.of(context).disabledColor),
        ),
        useFullName: false,
      ),
    ];

    if (orientation == Axis.vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: widgets,
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: widgets,
      );
    }
  }
}
