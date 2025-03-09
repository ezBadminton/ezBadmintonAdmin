part of 'elimination_tree_layout.dart';

class DoubleEliminationTreeLayout extends StatelessWidget {
  DoubleEliminationTreeLayout({
    super.key,
    required this.winnerBracket,
    required this.winnerBracketSize,
    required List<List<Widget>> matchNodes,
    required Size layoutSize,
    required this.matchNodeSize,
    this.roundGapWidth = bracket_widths.singleEliminationRoundGap,
    this.relativeIntakeRoundOffset = bracket_widths.relativeIntakeRoundOffset,
  })  : _matchNodes = EliminationTreeLayout._createMatchNodes(matchNodes),
        _treeEdges = EliminationTreeLayout._createTreeEdges(
          matchNodes.take(matchNodes.length - 1),
          edgeBuilder: _treeEdgeBuilder,
        ),
        _finalTreeEdges = _createFinalTreeEdges(matchNodes),
        _loserEdges = _createLoserEdges(matchNodes),
        layoutSize = Size(
          max(layoutSize.width, winnerBracketSize.width),
          layoutSize.height +
              winnerBracketSize.height +
              _winnerLoserBracketMargin,
        );

  final Widget winnerBracket;
  final Size winnerBracketSize;

  final Size layoutSize;
  final Size matchNodeSize;

  final double roundGapWidth;

  final double relativeIntakeRoundOffset;

  final List<List<_MatchNode>> _matchNodes;

  final List<List<_TreeEdge>> _treeEdges;

  final List<_TreeEdge> _finalTreeEdges;

  final List<_LoserEdge> _loserEdges;

  static const double _winnerLoserBracketMargin = 100;

  static const String _winnerBracketId = 'final';

  @override
  Widget build(BuildContext context) {
    Widget winnerBracket = LayoutId(
      id: _winnerBracketId,
      child: this.winnerBracket,
    );

    return CustomMultiChildLayout(
      delegate: _DoubleEliminationTreeLayoutDelegate(
        winnerBracketSize: winnerBracketSize,
        matchNodes: _matchNodes,
        treeEdges: _treeEdges,
        finalTreeEdges: _finalTreeEdges,
        loserEdges: _loserEdges,
        matchNodeSize: matchNodeSize,
        layoutSize: layoutSize,
        roundGapWidth: roundGapWidth,
        relativeIntakeRoundOffset: relativeIntakeRoundOffset,
      ),
      children: [
        winnerBracket,
        ..._matchNodes.flattened,
        ..._treeEdges.flattened,
        ..._finalTreeEdges,
        ..._loserEdges,
      ],
    );
  }

  static List<_TreeEdge> _createFinalTreeEdges(
    Iterable<List<Widget>> matchWidgets,
  ) {
    int finalRoundIndex = matchWidgets.length - 1;

    List<_TreeEdge> finalEdges = [
      _TreeEdge(
        roundIndex: finalRoundIndex - 1,
        indexInRound: 100000,
        type: _TreeEdgeType.outgoing,
      ),
      _TreeEdge(
        roundIndex: finalRoundIndex - 1,
        indexInRound: 100001,
        type: _TreeEdgeType.outgoing,
      ),
      _TreeEdge(
        roundIndex: finalRoundIndex,
        indexInRound: 0,
        type: _TreeEdgeType.incoming,
      ),
    ];

    return finalEdges;
  }

  static List<_LoserEdge> _createLoserEdges(
    Iterable<List<Widget>> matchWidgets,
  ) {
    int numEdges = matchWidgets.length ~/ 2 + 1;

    return List.generate(numEdges, (index) => _LoserEdge(index: index));
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
    required this.winnerBracketSize,
    required this.finalTreeEdges,
    required this.loserEdges,
    required super.matchNodes,
    required super.treeEdges,
    required super.matchNodeSize,
    required super.layoutSize,
    required super.roundGapWidth,
    required this.relativeIntakeRoundOffset,
  }) : baseRoundSize = matchNodes.first.length;

  final Size winnerBracketSize;

  final List<_TreeEdge> finalTreeEdges;

  final List<_LoserEdge> loserEdges;

  final int baseRoundSize;

  final double relativeIntakeRoundOffset;

  @override
  Size getSize(BoxConstraints constraints) => layoutSize;

  @override
  void performLayout(Size size) {
    layoutChild(
      DoubleEliminationTreeLayout._winnerBracketId,
      const BoxConstraints(),
    );

    super.performLayout(size);

    positionFinal();
    layoutAndPositionFinalTreeEdges();
    layoutAndPositionLoserEdges();
  }

  @override
  void positionMatchNodes() {
    for (int round = 0; round < numRounds - 1; round += 1) {
      List<_MatchNode> roundMatchNodes = matchNodes[round];

      double nodeMargin = getVerticalNodeMargin(roundMatchNodes.length);

      double horizontalPostition = getHorizontalNodePosition(round);

      for (_MatchNode matchNode in roundMatchNodes) {
        double verticalPostition =
            getVerticalNodePosition(nodeMargin, matchNode);

        Offset nodePosition = Offset(horizontalPostition, verticalPostition);

        positionChild(
          matchNode.id,
          nodePosition,
        );

        _nodePositions.putIfAbsent(
          (matchNode.roundIndex, matchNode.indexInRound),
          () => nodePosition,
        );
      }
    }
  }

  void positionFinal() {
    _MatchNode finalMatchNode = matchNodes.last.single;

    Offset finalPosition = getFinalPosition();

    positionChild(finalMatchNode.id, finalPosition);
    _nodePositions.putIfAbsent(
      (finalMatchNode.roundIndex, finalMatchNode.indexInRound),
      () => finalPosition,
    );
  }

  @override
  void layoutTreeEdges() {
    for (int round = 0; round < numRounds - 1; round += 1) {
      double nodeMargin = getVerticalNodeMargin(matchNodes[round].length);

      List<_TreeEdge> roundTreeEdges = treeEdges[round];

      for (_TreeEdge edge in roundTreeEdges) {
        double height = switch ((edge.type, round.isOdd)) {
          (_TreeEdgeType.outgoing, true) =>
            _matchNodeSize.height * 0.5 + nodeMargin * 0.5,
          _ => 0,
        };

        double width = switch (edge) {
          _TreeEdge(
            type: _TreeEdgeType.incoming,
            roundIndex: int(isOdd: true),
          ) =>
            roundGapWidth,
          _TreeEdge(
            type: _TreeEdgeType.outgoing,
            roundIndex: int(isEven: true),
          ) =>
            0,
          _ => roundGapWidth * 0.5,
        };

        layoutChild(
          edge.id,
          BoxConstraints.tight(Size(width, height)),
        );
      }
    }
  }

  /// Since the final match is the odd match node that has edges coming from
  /// the winner bracket and the loser bracket, this method handles the
  /// special layout and positioning of the three final tree edges.
  ///
  /// This includes the one coming from the winner bracket final, the one
  /// from the loser bracket final and horizontal one mergin the previous two
  /// and leading into the final match node.
  void layoutAndPositionFinalTreeEdges() {
    _MatchNode finalNode = matchNodes.last.single;
    _MatchNode loserFinalNode = matchNodes[numRounds - 2].single;

    Offset finalPosition = _nodePositions[(
      finalNode.roundIndex,
      finalNode.indexInRound,
    )]!;
    Offset loserFinalPosition = _nodePositions[(
      loserFinalNode.roundIndex,
      loserFinalNode.indexInRound
    )]!;
    Offset winnerFinalOutgoingPoint = Offset(
      winnerBracketSize.width,
      winnerBracketSize.height * 0.5,
    );

    Offset loserFinalOutgoingPoint = loserFinalPosition +
        Offset(_matchNodeSize.width, _matchNodeSize.height * 0.5);

    Offset finalIncomingPoint = finalPosition +
        Offset(-roundGapWidth * 0.5, _matchNodeSize.height * 0.5);

    for (_TreeEdge edge in finalTreeEdges) {
      Size edgeSize = switch (edge) {
        _TreeEdge(type: _TreeEdgeType.incoming) => Size(roundGapWidth * 0.5, 0),
        _TreeEdge(goesDown: true) =>
          Rect.fromPoints(winnerFinalOutgoingPoint, finalIncomingPoint).size,
        _TreeEdge(goesDown: false) =>
          Rect.fromPoints(loserFinalOutgoingPoint, finalIncomingPoint).size,
      };

      layoutChild(edge.id, BoxConstraints.tight(edgeSize));

      Offset edgePosition = switch (edge) {
        _TreeEdge(type: _TreeEdgeType.incoming) => finalIncomingPoint,
        _TreeEdge(goesDown: true) => winnerFinalOutgoingPoint,
        _TreeEdge(goesDown: false) =>
          finalIncomingPoint + Offset(-roundGapWidth * 0.5, 0),
      };

      positionChild(edge.id, edgePosition);
    }
  }

  void layoutAndPositionLoserEdges() {
    List<List<_MatchNode>> intakeRounds = matchNodes
        .take(1)
        .followedBy(matchNodes.whereIndexed((index, _) => index.isOdd))
        .toList();

    assert(intakeRounds.length == loserEdges.length);

    double verticalBasePosition = winnerBracketSize.height;

    for (_LoserEdge edge in loserEdges) {
      double nodeMargin = super.getVerticalNodeMargin(edge.index);

      double horizontalStartPosition =
          super.getHorizontalNodePosition(edge.index) +
              _matchNodeSize.width * 0.5;

      double verticalStartPosition = verticalBasePosition - nodeMargin * 0.5;

      Offset startPosition =
          Offset(horizontalStartPosition, verticalStartPosition);

      _MatchNode endNode = intakeRounds[edge.index].first;

      Offset endNodePosition =
          _nodePositions[(endNode.roundIndex, endNode.indexInRound)]!;

      Offset endPosition =
          endNodePosition + Offset(_matchNodeSize.width * 0.5, 0);

      Rect loserEdgeRect = Rect.fromPoints(startPosition, endPosition);

      layoutChild(edge.id, BoxConstraints.tight(loserEdgeRect.size));
      positionChild(edge.id, loserEdgeRect.topLeft);
    }
  }

  @override
  void positionTreeEdges() {
    for (int round = 0; round < numRounds - 1; round += 1) {
      List<_TreeEdge> roundTreeEdges = treeEdges[round];

      double nodeMargin = getVerticalNodeMargin(matchNodes[round].length);

      for (_TreeEdge edge in roundTreeEdges) {
        Offset nodePosition =
            _nodePositions[(edge.roundIndex, edge.indexInRound)]!;

        Offset edgePosition =
            nodePositionToEdgePosition(nodePosition, edge, nodeMargin);

        positionChild(edge.id, edgePosition);
      }
    }
  }

  @override
  double getVerticalNodeMargin(int roundSize) {
    int round = log2(baseRoundSize ~/ roundSize);
    return super.getVerticalNodeMargin(round);
  }

  @override
  double getVerticalNodePosition(
    double nodeMargin,
    _TournamentTreePosition treePosition,
  ) {
    return utils.getVerticalLoserBracketNodePosition(
      nodeMargin,
      treePosition.roundIndex,
      treePosition.indexInRound,
      winnerBracketSize,
      _matchNodeSize,
      DoubleEliminationTreeLayout._winnerLoserBracketMargin,
    );
  }

  @override
  Offset nodePositionToEdgePosition(
    Offset nodePosition,
    _TreeEdge edge,
    double nodeMargin,
  ) {
    Offset edgeOffset = switch (edge) {
      _TreeEdge(type: _TreeEdgeType.incoming, roundIndex: int(isOdd: true)) =>
        Offset(
          -roundGapWidth,
          _matchNodeSize.height * (0.5 + relativeIntakeRoundOffset),
        ),
      _TreeEdge(type: _TreeEdgeType.incoming) =>
        Offset(-roundGapWidth * 0.5, _matchNodeSize.height * 0.5),
      _TreeEdge(goesDown: true) =>
        Offset(_matchNodeSize.width, _matchNodeSize.height * 0.5),
      _TreeEdge(goesDown: false) =>
        Offset(_matchNodeSize.width, -nodeMargin * 0.5),
    };

    return nodePosition + edgeOffset;
  }

  Offset getFinalPosition() {
    double horizontalPostition =
        getHorizontalNodePosition(matchNodes.length - 1);

    double verticalPostion =
        layoutSize.height * 0.5 - _matchNodeSize.height * 0.5;

    Offset finalPosition = Offset(horizontalPostition, verticalPostion);

    return finalPosition;
  }

  @override
  bool shouldRelayout(_DoubleEliminationTreeLayoutDelegate oldDelegate) {
    return true;
  }
}

class _LoserEdge extends LayoutId {
  _LoserEdge({
    required this.index,
  }) : super(
          child: const SLine(color: Colors.black26),
          id: 'LoserEdge-$index',
        );

  final int index;
}
