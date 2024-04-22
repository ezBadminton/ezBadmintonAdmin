import 'dart:math';

import 'package:flutter/material.dart';

/// Returns the total vertical margin of the match nodes of a given [round].
///
/// That is each node has half this space in the top and bottom direction from
/// its edges.
double getVerticalNodeMargin(int round, double matchNodeHeight) {
  int relativeNodeMargin = (pow(2, round) as int) - 1;

  double absoluteNodeMargin = relativeNodeMargin * matchNodeHeight;

  return absoluteNodeMargin;
}

/// Returns the horizontal position (y-coordinate) of a match node that
/// has the [indexInRound]. The [nodeMargin] is the vertical node margin
/// of that round (see [getVerticalNodeMargin]).
double getVerticalNodePosition(
  double matchNodeHeight,
  double nodeMargin,
  int indexInRound,
) {
  double topMargin = nodeMargin * 0.5;

  double totalNodeHeight = nodeMargin + matchNodeHeight;

  double verticalPosition = topMargin + indexInRound * totalNodeHeight;

  return verticalPosition;
}

double getVerticalLoserBracketNodePosition(
  double nodeMargin,
  int roundIndex,
  int indexInRound,
  Size winnerBracketSize,
  Size nodeSize,
  double loserBracketMargin, {
  double relativeIntakeRoundOffset = 0.2,
}) {
  double basePosition =
      getVerticalNodePosition(nodeSize.height, nodeMargin, indexInRound);

  double winnerBracketOffset = winnerBracketSize.height + loserBracketMargin;

  double firstIntakeOffset = nodeSize.height * relativeIntakeRoundOffset;

  int intakeRound = (roundIndex + 1) ~/ 2;
  double intakeOffset =
      -nodeSize.height * intakeRound * relativeIntakeRoundOffset;

  return basePosition + winnerBracketOffset + firstIntakeOffset + intakeOffset;
}
