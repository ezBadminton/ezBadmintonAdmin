import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/match_participant_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MatchLabel extends StatelessWidget {
  const MatchLabel({
    super.key,
    required this.match,
    required this.competition,
  });

  final BadmintonMatch match;
  final Competition competition;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        MatchParticipantLabel(
          match.a,
          teamSize: competition.teamSize,
          isEditable: false,
          width: 200,
          alignment: CrossAxisAlignment.end,
          byeLabel: l10n.freeOfPlay,
        ),
        const SizedBox(width: 12),
        const Text(
          '-',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 12),
        MatchParticipantLabel(
          match.b,
          teamSize: competition.teamSize,
          isEditable: false,
          width: 200,
          byeLabel: l10n.freeOfPlay,
        ),
      ],
    );
  }
}
