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
