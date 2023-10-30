import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/widgets/competition_label/competition_label.dart';
import 'package:ez_badminton_admin_app/widgets/match_info/match_info.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/match_participant_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MatchLabel extends StatelessWidget {
  const MatchLabel({
    super.key,
    required this.match,
    this.infoStyle = const TextStyle(fontSize: 12),
    this.opponentStyle = const TextStyle(fontSize: 16),
  });

  final BadmintonMatch match;

  final TextStyle infoStyle;
  final TextStyle opponentStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CompetitionLabel(
          competition: match.competition,
          textStyle: infoStyle,
          dividerPadding: 6,
        ),
        const SizedBox(height: 5),
        RunningMatchInfo(match: match, textStyle: infoStyle),
        const SizedBox(height: 5),
        MatchupLabel(
          match: match,
          orientation: Axis.horizontal,
          textStyle: opponentStyle,
        ),
        const SizedBox(height: 5),
        Text(match.court!.name, style: infoStyle),
      ],
    );
  }
}

class MatchupLabel extends StatelessWidget {
  const MatchupLabel({
    super.key,
    required this.match,
    this.orientation = Axis.vertical,
    this.participantWidth = 185,
    this.useFullName = false,
    this.boldLastName = false,
    this.textStyle,
  });

  final BadmintonMatch match;

  final Axis orientation;

  final double participantWidth;

  final bool useFullName;

  final bool boldLastName;

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    TextStyle? lastNameTextStyle =
        boldLastName ? const TextStyle(fontWeight: FontWeight.bold) : null;

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
        useFullName: useFullName,
        textStyle: textStyle,
        lastNametextStyle: lastNameTextStyle,
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
        useFullName: useFullName,
        textStyle: textStyle,
        lastNametextStyle: lastNameTextStyle,
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
