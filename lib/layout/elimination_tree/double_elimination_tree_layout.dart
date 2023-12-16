part of 'elimination_tree_layout.dart';

class DoubleEliminationTreeLayout extends StatelessWidget {
  DoubleEliminationTreeLayout({
    super.key,
    required this.winnerBracket,
    required List<List<Widget>> matchNodes,
    required this.matchNodeSize,
    this.roundGapWidth = 25,
  })  : _matchNodes = EliminationTreeLayout._createMatchNodes(matchNodes),
        _treeEdges = EliminationTreeLayout._createTreeEdges(
          matchNodes,
          edgeBuilder: _treeEdgeBuilder,
        );

  final Widget winnerBracket;

  final Size matchNodeSize;

  final double roundGapWidth;

  final List<List<_MatchNode>> _matchNodes;

  final List<List<_TreeEdge>> _treeEdges;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        winnerBracket,
        CustomMultiChildLayout(
          delegate: _DoubleEliminationTreeLayoutDelegate(
            matchNodes: _matchNodes,
            treeEdges: _treeEdges,
            matchNodeSize: matchNodeSize,
            roundGapWidth: roundGapWidth,
          ),
          children: [
            ..._matchNodes.flattened,
            //..._treeEdges.flattened,
          ],
        ),
      ],
    );
  }

  static Widget _treeEdgeBuilder(
    _TreeEdgeType type,
    int roundIndex,
    int indexInRound,
  ) {
    _TreeEdgeType edgeType = roundIndex.isEven ? _TreeEdgeType.incoming : type;

    return _TreeEdgeWidget(
      type: edgeType,
      indexInRound: indexInRound,
    );
  }
}

class _DoubleEliminationTreeLayoutDelegate
    extends _ElimiationTreeLayoutDelegate {
  _DoubleEliminationTreeLayoutDelegate({
    required super.matchNodes,
    required super.treeEdges,
    required super.matchNodeSize,
    required super.roundGapWidth,
  }) : baseRoundSize = matchNodes.first.length;

  final int baseRoundSize;

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(
      numRounds * matchNodeSize.width + (numRounds - 1) * roundGapWidth,
      matchNodes.first.length * matchNodeSize.height +
          matchNodeSize.height * 0.25,
    );
  }

  @override
  void performLayout(Size size) {
    layoutMatchNodes();
    positionMatchNodes();
  }

  @override
  void positionMatchNodes() {
    for (int round = 0; round < numRounds; round += 1) {
      List<_MatchNode> roundMatchNodes = matchNodes[round];

      int relativeNodeMargin = getRelativeNodeMargin(roundMatchNodes.length);
      double nodeMargin = relativeNodeMargin * _matchNodeSize.height * 0.5;

      double horizontalPostition = getHorizontalNodePosition(round);

      int upshifts = (round + 1) ~/ 2;
      double verticalOffset = -_matchNodeSize.height * upshifts * 0.25;

      for ((int, _MatchNode) matchNodeEntry in roundMatchNodes.indexed) {
        int indexInRound = matchNodeEntry.$1;
        _MatchNode matchNode = matchNodeEntry.$2;

        double verticalPostition =
            getVerticalNodePosition(nodeMargin, indexInRound) +
                _matchNodeSize.height * 0.25 +
                verticalOffset;

        positionChild(
          matchNode.id,
          Offset(horizontalPostition, verticalPostition),
        );
      }
    }
  }

  @override
  int getRelativeNodeMargin(int roundSize) {
    int round = log2(baseRoundSize ~/ roundSize);
    return (pow(2, round + 1) as int) - 2;
  }

  @override
  bool shouldRelayout(_DoubleEliminationTreeLayoutDelegate oldDelegate) {
    return true;
  }
}
