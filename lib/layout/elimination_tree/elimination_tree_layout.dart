import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dart_numerics/dart_numerics.dart';
import 'package:ez_badminton_admin_app/widgets/bent_line/bent_line.dart';
import 'package:flutter/material.dart';

part 'double_elimination_tree_layout.dart';

/// This widget arranges the match nodes of an elimination tournament in a
/// left-to-right flowing tree layout.
///
/// The visual tree edges connecting the matches are automatically added.
class EliminationTreeLayout extends StatelessWidget {
  /// Creates a widget that visually represents an elimination tournament tree.
  ///
  /// The [matchNodes] sublists need to be ordered from first round to final
  /// round.
  EliminationTreeLayout({
    super.key,
    required List<List<Widget>> matchNodes,
    required this.matchNodeSize,
    this.roundGapWidth = 25,
  })  : _matchNodes = _createMatchNodes(matchNodes),
        _treeEdges = _createTreeEdges(matchNodes);

  /// The match node size has to be known so the entire tree's size can be
  /// calculated without making a speculative layout
  /// (which is not supported by [CustomMultiChildLayout]).
  ///
  /// The [matchNodes] have to take this size when they are layed out.
  final Size matchNodeSize;

  final List<List<_MatchNode>> _matchNodes;

  final List<List<_TreeEdge>> _treeEdges;

  /// The horizontal gap between the rounds contains the tree edges.
  ///
  /// A vertical gap between the matches of a round has to be added as padding
  /// of the node widgets themselves.
  final double roundGapWidth;

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _ElimiationTreeLayoutDelegate(
        matchNodes: _matchNodes,
        treeEdges: _treeEdges,
        matchNodeSize: matchNodeSize,
        roundGapWidth: roundGapWidth,
      ),
      children: [
        ..._matchNodes.flattened,
        ..._treeEdges.flattened,
      ],
    );
  }

  /// Wrap each match widget in a [_MatchNode].
  ///
  /// The [_MatchNode] identifies each match widget to the
  /// [_ElimiationTreeLayoutDelegate] so it can position it at the appropriate
  /// location.
  static List<List<_MatchNode>> _createMatchNodes(
      List<List<Widget>> matchWidgets) {
    List<List<_MatchNode>> matchNodes = [];

    for ((int, List<Widget>) roundEntry in matchWidgets.indexed) {
      int roundIndex = roundEntry.$1;
      List<Widget> roundWidgets = roundEntry.$2;

      List<_MatchNode> roundMatchNodes = roundWidgets
          .mapIndexed(
            (indexInRound, matchWidget) => _MatchNode(
              roundIndex: roundIndex,
              indexInRound: indexInRound,
              child: matchWidget,
            ),
          )
          .toList();

      matchNodes.add(roundMatchNodes);
    }

    return matchNodes;
  }

  static List<List<_TreeEdge>> _createTreeEdges(
    List<List<Widget>> matchWidgets, {
    Widget Function(_TreeEdgeType type, int roundIndex, int indexInRound)?
        edgeBuilder,
  }) {
    int numRounds = matchWidgets.length;

    List<List<_TreeEdge>> treeEdges = [];

    for ((int, List<Widget>) roundEntry in matchWidgets.indexed) {
      List<_TreeEdge> roundEdges = [];

      int roundIndex = roundEntry.$1;
      int roundSize = roundEntry.$2.length;

      if (roundIndex > 0) {
        List<_TreeEdge> incomingEdges = List.generate(
          roundSize,
          (indexInRound) => _TreeEdge(
            roundIndex: roundIndex,
            indexInRound: indexInRound,
            type: _TreeEdgeType.incoming,
            builder: edgeBuilder,
          ),
        );

        roundEdges.addAll(incomingEdges);
      }

      if (roundIndex < numRounds - 1) {
        List<_TreeEdge> outgoingEdges = List.generate(
          roundSize,
          (indexInRound) => _TreeEdge(
            roundIndex: roundIndex,
            indexInRound: indexInRound,
            type: _TreeEdgeType.outgoing,
          ),
        );

        roundEdges.addAll(outgoingEdges);
      }

      treeEdges.add(roundEdges);
    }

    return treeEdges;
  }
}

class _ElimiationTreeLayoutDelegate extends MultiChildLayoutDelegate {
  _ElimiationTreeLayoutDelegate({
    required this.matchNodes,
    required this.treeEdges,
    required this.matchNodeSize,
    required this.roundGapWidth,
  }) : numRounds = matchNodes.length;

  final List<List<_MatchNode>> matchNodes;

  final List<List<_TreeEdge>> treeEdges;

  final int numRounds;

  final Size matchNodeSize;
  final double roundGapWidth;

  late Size _matchNodeSize;

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(
      numRounds * matchNodeSize.width + (numRounds - 1) * roundGapWidth,
      matchNodes.first.length * matchNodeSize.height,
    );
  }

  @override
  void performLayout(Size size) {
    layoutMatchNodes();
    positionMatchNodes();

    layoutTreeEdges();
    positionTreeEdges();
  }

  void layoutMatchNodes() {
    for (_MatchNode matchNode in matchNodes.flattened) {
      Size matchNodeSize = layoutChild(matchNode.id, const BoxConstraints());

      assert(
        matchNode == matchNodes.flattened.first ||
            _matchNodeSize == matchNodeSize,
        "All match nodes have to be the same size!",
      );

      _matchNodeSize = matchNodeSize;
    }
  }

  void positionMatchNodes() {
    for (int round = 0; round < numRounds; round += 1) {
      int relativeNodeMargin = getRelativeNodeMargin(round);
      double nodeMargin = relativeNodeMargin * _matchNodeSize.height * 0.5;

      double horizontalPostition = getHorizontalNodePosition(round);

      List<_MatchNode> roundMatchNodes = matchNodes[round];

      for ((int, _MatchNode) matchNodeEntry in roundMatchNodes.indexed) {
        int indexInRound = matchNodeEntry.$1;
        _MatchNode matchNode = matchNodeEntry.$2;

        double verticalPostition =
            getVerticalNodePosition(nodeMargin, indexInRound);

        positionChild(
          matchNode.id,
          Offset(horizontalPostition, verticalPostition),
        );
      }
    }
  }

  void layoutTreeEdges() {
    for (int round = 0; round < numRounds; round += 1) {
      int relativeNodeMargin = getRelativeNodeMargin(round);
      double nodeMargin = relativeNodeMargin * _matchNodeSize.height * 0.5;

      List<_TreeEdge> roundTreeEdges = treeEdges[round];

      for (_TreeEdge edge in roundTreeEdges) {
        double height = switch (edge.type) {
          _TreeEdgeType.incoming => 0,
          _TreeEdgeType.outgoing =>
            _matchNodeSize.height * 0.5 + nodeMargin * 0.5,
        };

        layoutChild(
          edge.id,
          BoxConstraints.tight(Size(roundGapWidth * 0.5, height)),
        );
      }
    }
  }

  void positionTreeEdges() {
    for (int round = 0; round < numRounds; round += 1) {
      int relativeNodeMargin = getRelativeNodeMargin(round);
      double nodeMargin = relativeNodeMargin * _matchNodeSize.height * 0.5;

      double horizontalNodePostition = getHorizontalNodePosition(round);

      List<_TreeEdge> roundTreeEdges = treeEdges[round];

      for (_TreeEdge edge in roundTreeEdges) {
        double verticalNodePostition =
            getVerticalNodePosition(nodeMargin, edge.indexInRound);

        Offset nodePosition =
            Offset(horizontalNodePostition, verticalNodePostition);

        Offset edgePosition =
            nodePositionToEdgePosition(nodePosition, edge, nodeMargin);

        positionChild(edge.id, edgePosition);
      }
    }
  }

  double getHorizontalNodePosition(int round) {
    return round * (_matchNodeSize.width + roundGapWidth);
  }

  double getVerticalNodePosition(double nodeMargin, int indexInRound) {
    return 0.5 * nodeMargin +
        indexInRound * (nodeMargin + _matchNodeSize.height);
  }

  int getRelativeNodeMargin(int round) {
    return (pow(2, round + 1) as int) - 2;
  }

  Offset nodePositionToEdgePosition(
    Offset nodePosition,
    _TreeEdge edge,
    double nodeMargin,
  ) {
    Offset edgeOffset = switch (edge) {
      _TreeEdge(type: _TreeEdgeType.incoming) =>
        Offset(-roundGapWidth * 0.5, _matchNodeSize.height * 0.5),
      _TreeEdge(goesDown: true) =>
        Offset(_matchNodeSize.width, _matchNodeSize.height * 0.5),
      _TreeEdge(goesDown: false) =>
        Offset(_matchNodeSize.width, -nodeMargin * 0.5),
    };

    return nodePosition + edgeOffset;
  }

  @override
  bool shouldRelayout(_ElimiationTreeLayoutDelegate oldDelegate) {
    return true;
  }
}

class _MatchNode extends LayoutId {
  _MatchNode({
    required int roundIndex,
    required int indexInRound,
    required super.child,
  }) : super(id: (roundIndex, indexInRound));
}

class _TreeEdge extends LayoutId {
  _TreeEdge({
    required this.roundIndex,
    required this.indexInRound,
    required this.type,
    Widget Function(_TreeEdgeType type, int roundIndex, int indexInRound)?
        builder,
  }) : super(
          id: (roundIndex, indexInRound, type),
          child:
              (builder ?? _defaultBuilder).call(type, roundIndex, indexInRound),
        );

  final int roundIndex;
  final int indexInRound;

  final _TreeEdgeType type;

  bool get goesDown => indexInRound.isEven;

  static Widget _defaultBuilder(
    _TreeEdgeType type,
    int roundIndex,
    int indexInRound,
  ) {
    return _TreeEdgeWidget(
      type: type,
      indexInRound: indexInRound,
    );
  }
}

class _TreeEdgeWidget extends StatelessWidget {
  const _TreeEdgeWidget({
    required this.type,
    required this.indexInRound,
  });

  final _TreeEdgeType type;

  final int indexInRound;

  bool get goesDown => indexInRound.isEven;

  @override
  Widget build(BuildContext context) {
    Color treeArmColor =
        Theme.of(context).colorScheme.onSurface.withOpacity(.85);
    double treeArmThickness = 1.3;

    return switch (type) {
      _TreeEdgeType.incoming => Divider(
          height: 0,
          thickness: treeArmThickness,
          color: treeArmColor,
        ),
      _TreeEdgeType.outgoing => BentLine(
          bendCorner: goesDown ? Corner.topRight : Corner.bottomRight,
          bendRadius: 5.0,
          thickness: treeArmThickness,
          color: treeArmColor,
        ),
    };
  }
}

enum _TreeEdgeType {
  incoming,
  outgoing,
}
