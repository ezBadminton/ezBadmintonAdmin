import 'package:collection_repository/collection_repository.dart';
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
    required this.showResult,
    this.placeholderLabels = const {},
  });

  final BadmintonMatch match;
  final int teamSize;

  /// The index of the match within its round
  final int matchIndex;
  final bool isFirstRound;
  final bool isLastRound;
  final bool isEditable;
  final bool showResult;

  final Map<MatchParticipant, String> placeholderLabels;

  @override
  Widget build(BuildContext context) {
    double width = isEditable && isFirstRound
        ? bracket_widths.editableSingleEliminationNodeWidth
        : bracket_widths.singleEliminatioNodeWith;

    MatchParticipant? winner = showResult ? match.getWinner() : null;

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
      child: IntrinsicHeight(
        child: Row(
          children: [
            Column(
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
                  alignment: showResult
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  textStyle: winner == match.a
                      ? TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        )
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
                  placeholderLabel: placeholderLabels.containsKey(match.b)
                      ? Text(placeholderLabels[match.b]!)
                      : null,
                  alignment: showResult
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  textStyle: winner == match.b
                      ? TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        )
                      : null,
                ),
              ],
            ),
            if (showResult) _Scoreline(match: match),
          ],
        ),
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

class _Scoreline extends StatelessWidget {
  const _Scoreline({
    required this.match,
  });

  final BadmintonMatch match;

  @override
  Widget build(BuildContext context) {
    int maxSets = match.competition.tournamentModeSettings!.winningSets * 2 - 1;

    List<(int, int)?> scores = List.generate(
      maxSets,
      (index) {
        MatchSet? set = match.score?.elementAtOrNull(index);

        return set == null ? null : (set.team1Points, set.team2Points);
      },
    );

    List<Widget> scoreColumns = scores.map(
      (score) {
        bool? winner1 = score == null ? null : score.$1 > score.$2;
        bool? winner2 = score == null ? null : score.$2 > score.$1;
        Widget score1 = _buildScoreNumber(
          context,
          score?.$1,
          winner1,
          match.isCompleted,
        );
        Widget score2 = _buildScoreNumber(
          context,
          score?.$2,
          winner2,
          match.isCompleted,
        );

        return _ScoreContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Center(child: score1),
              ),
              Divider(
                height: 0,
                thickness: 1,
                color: Theme.of(context).primaryColor.withOpacity(.55),
              ),
              Expanded(
                child: Center(child: score2),
              ),
            ],
          ),
        );
      },
    ).toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (Widget column in scoreColumns) ...[
          if (scoreColumns.first != column)
            VerticalDivider(
              width: 2,
              thickness: 2,
              color: Theme.of(context).primaryColor.withOpacity(.55),
            ),
          column,
        ],
      ],
    );
  }

  Widget _buildScoreNumber(
    BuildContext context,
    int? score,
    bool? isWinner,
    bool isMatchComplete,
  ) {
    if (score == null) {
      if (isMatchComplete) {
        return Text(
          '⟋',
          style: TextStyle(
            fontSize: 15,
            color: Theme.of(context).disabledColor,
          ),
        );
      } else {
        return const SizedBox();
      }
    }

    return Text(
      '$score',
      style: TextStyle(
        fontSize: 17,
        fontWeight: isWinner! ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class _ScoreContainer extends StatelessWidget {
  const _ScoreContainer({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      color: Theme.of(context).primaryColorLight,
      child: child,
    );
  }
}
