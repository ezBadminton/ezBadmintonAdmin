import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/widgets/bent_line/bent_line.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/match_participant_label.dart';
import 'package:flutter/material.dart';
import 'package:tournament_mode/tournament_mode.dart';
import 'bracket_widths.dart' as bracket_widths;

class SingleEliminationMatchNode extends StatelessWidget {
  const SingleEliminationMatchNode({
    super.key,
    required this.match,
    required this.teamSize,
    required this.matchIndex,
    required this.isFirstRound,
    required this.isLastRound,
    required this.isEditable,
    this.placeholderLabels = const {},
  });

  final BadmintonMatch match;
  final int teamSize;

  /// The index of the match within its round
  final int matchIndex;
  final bool isFirstRound;
  final bool isLastRound;
  final bool isEditable;

  final Map<MatchParticipant, String> placeholderLabels;

  @override
  Widget build(BuildContext context) {
    double width = isEditable && isFirstRound
        ? bracket_widths.editableSingleEliminationNodeWidth
        : bracket_widths.singleEliminatioNodeWith;

    Widget matchCard = Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MatchParticipantLabel(
            match.a,
            teamSize: teamSize,
            isEditable: isEditable && isFirstRound,
            width: width,
            placeholderLabel: placeholderLabels.containsKey(match.a)
                ? Text(placeholderLabels[match.a]!)
                : null,
          ),
          SizedBox(
            width: width,
            child: const Divider(height: 0, thickness: 1),
          ),
          MatchParticipantLabel(
            match.b,
            teamSize: teamSize,
            isEditable: isEditable && isFirstRound,
            width: width,
            placeholderLabel: placeholderLabels.containsKey(match.a)
                ? Text(placeholderLabels[match.a]!)
                : null,
          ),
        ],
      ),
    );

    Color treeArmColor =
        Theme.of(context).colorScheme.onSurface.withOpacity(.85);
    double treeArmThickness = 1.3;

    Widget incomingTreeArm = SizedBox(
      width: bracket_widths.singleEliminationRoundGap * 0.5,
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
          width: bracket_widths.singleEliminationRoundGap * 0.5,
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
