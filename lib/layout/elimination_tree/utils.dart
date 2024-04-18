import 'dart:math';

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
