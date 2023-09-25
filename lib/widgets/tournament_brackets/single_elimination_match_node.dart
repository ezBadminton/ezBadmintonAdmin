import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/draw_management/models/badminton_match.dart';
import 'package:ez_badminton_admin_app/widgets/bent_line/bent_line.dart';
import 'package:flutter/material.dart';
import 'package:tournament_mode/tournament_mode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

class SingleEliminationMatchNode extends StatelessWidget {
  const SingleEliminationMatchNode({
    super.key,
    required this.match,
    required this.teamSize,
    required this.matchIndex,
    required this.isFirstRound,
    required this.isLastRound,
  });

  final BadmintonMatch match;
  final int teamSize;

  /// The index of the match within its round
  final int matchIndex;
  final bool isFirstRound;
  final bool isLastRound;

  @override
  Widget build(BuildContext context) {
    Widget matchCard = Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(.3),
          width: 2,
        ),
      ),
      child: SizedBox(
        width: 220,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 2.0,
              ),
              child: _MatchParticipantLabel(match.a, teamSize: teamSize),
            ),
            const Divider(height: 0),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 2.0,
              ),
              child: _MatchParticipantLabel(match.b, teamSize: teamSize),
            ),
          ],
        ),
      ),
    );

    Color treeArmColor =
        Theme.of(context).colorScheme.onSurface.withOpacity(.85);
    double treeArmThickness = 1.3;

    Widget incomingTreeArm = SizedBox(
      width: 10,
      child: Divider(
        height: 0,
        thickness: treeArmThickness,
        color: treeArmColor,
      ),
    );

    bool isEven = matchIndex.isEven;
    Widget outgoingTreeArm = Align(
      alignment: isEven ? Alignment.bottomCenter : Alignment.topCenter,
      child: FractionallySizedBox(
        heightFactor: .5,
        child: SizedBox(
          width: 10,
          child: BentLine(
            bendCorner: isEven ? Corner.topRight : Corner.bottomRight,
            bendRadius: 5.0,
            thickness: treeArmThickness,
            color: treeArmColor,
          ),
        ),
      ),
    );

    return IntrinsicHeight(
      child: Row(
        children: [
          if (!isFirstRound) incomingTreeArm,
          matchCard,
          if (!isLastRound) outgoingTreeArm,
        ],
      ),
    );
  }
}

class _MatchParticipantLabel extends StatelessWidget {
  const _MatchParticipantLabel(
    this.participant, {
    required this.teamSize,
  });

  final MatchParticipant<Team> participant;
  final int teamSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _createParticipantLabels(context, participant),
    );
  }

  List<Text> _createParticipantLabels(
    BuildContext context,
    MatchParticipant<Team> participant,
  ) {
    var l10n = AppLocalizations.of(context)!;

    TextStyle placeholderStyle = TextStyle(
      color: Theme.of(context).disabledColor,
    );

    if (participant.isBye) {
      return [
        Text(
          l10n.bye,
          style: placeholderStyle,
        ),
        ...List.generate(teamSize - 1, (index) => const Text('')),
      ];
    }

    Team? team = participant.resolvePlayer();

    if (team == null) {
      return List.generate(teamSize, (index) => const Text(''));
    }

    return [
      for (Player player in team.players)
        Text(display_strings.playerName(player)),
    ];
  }
}
