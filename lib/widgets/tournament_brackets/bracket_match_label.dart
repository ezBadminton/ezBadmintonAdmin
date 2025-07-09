import 'package:ez_badminton_admin_app/widgets/tournament_brackets/slot_label.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_context/tournament_context.dart';
import 'package:flutter/material.dart';
import 'package:ez_badminton_admin_app/l10n/l10n.dart';

class BracketMatchLabel extends StatelessWidget {
  const BracketMatchLabel({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    var tPlan = context.readTournamentPlan();
    var match = context.readMatch();
    var competition = tPlan.competition;

    return Row(
      children: [
        SlotLabel(
          match.slot1,
          teamSize: competition.teamSize,
          width: 200,
          alignment: CrossAxisAlignment.end,
          byeLabel: Text(
            l10n.freeOfPlay,
            style: TextStyle(color: Theme.of(context).disabledColor),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          '-',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 12),
        SlotLabel(
          match.slot2,
          teamSize: competition.teamSize,
          width: 200,
          byeLabel: Text(
            l10n.freeOfPlay,
            style: TextStyle(color: Theme.of(context).disabledColor),
          ),
        ),
      ],
    );
  }
}
