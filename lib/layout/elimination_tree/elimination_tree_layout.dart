import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dart_numerics/dart_numerics.dart';
import 'package:ez_badminton_admin_app/widgets/line_painters/bent_line.dart';
import 'package:ez_badminton_admin_app/widgets/line_painters/s_line.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/bracket_sizes.dart'
    as bracket_widths;
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
    required this.layoutSize,
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

  final Size layoutSize;

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
        layoutSize: layoutSize,
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
      Iterable<List<Widget>> matchWidgets) {
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
    Iterable<List<Widget>> matchWidgets, {
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
            builder: edgeBuilder,
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
    required this.layoutSize,
    required this.roundGapWidth,
  }) : numRounds = matchNodes.length;

  final List<List<_MatchNode>> matchNodes;

  final List<List<_TreeEdge>> treeEdges;

  final int numRounds;

  final Size matchNodeSize;

  final Size layoutSize;

  final double roundGapWidth;

  late Size _matchNodeSize;

  final Map<(int, int), Offset> _nodePositions = {};

  @override
  Size getSize(BoxConstraints constraints) => layoutSize;

  @override
  void performLayout(Size size) {
    _nodePositions.clear();

    layoutMatchNodes();
    positionMatchNodes();

    layoutTreeEdges();
    positionTreeEdges();
  }

  void layoutMatchNodes() {
    for (_MatchNode matchNode in matchNodes.flattened) {
      Size matchNodeSize = layoutChild(matchNode.id, const BoxConstraints());

      //assert(
      //  matchNode == matchNodes.flattened.first ||
      //      _matchNodeSize == matchNodeSize,
      //  "All match nodes have to be the same size!",
      //);

      _matchNodeSize = matchNodeSize;
    }
  }

  void positionMatchNodes() {
    for (int round = 0; round < numRounds; round += 1) {
      double nodeMargin = getVerticalNodeMargin(round);

      double horizontalPostition = getHorizontalNodePosition(round);

      List<_MatchNode> roundMatchNodes = matchNodes[round];

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

  void layoutTreeEdges() {
    for (int round = 0; round < numRounds; round += 1) {
      double nodeMargin = getVerticalNodeMargin(round);

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
      double nodeMargin = getVerticalNodeMargin(round);

      List<_TreeEdge> roundTreeEdges = treeEdges[round];

      for (_TreeEdge edge in roundTreeEdges) {
        Offset nodePosition =
            _nodePositions[(edge.roundIndex, edge.indexInRound)]!;

        Offset edgePosition =
            nodePositionToEdgePosition(nodePosition, edge, nodeMargin);

        positionChild(edge.id, edgePosition);
      }
    }
  }

  /// Returns the vertical position (x-coordiante) of a match node that is
  /// part of the [round]. The first round is round 0.
  double getHorizontalNodePosition(int round) {
    double totalNodeWidth = _matchNodeSize.width + roundGapWidth;

    double horizontalPosition = round * totalNodeWidth;

    return horizontalPosition;
  }

  /// Returns the horizontal position (y-coordinate) of a match node that
  /// is in the [treePosition].
  double getVerticalNodePosition(
    double nodeMargin,
    _TournamentTreePosition treePosition,
  ) {
    double topMargin = nodeMargin * 0.5;

    double totalNodeHeight = nodeMargin + _matchNodeSize.height;

    double verticalPosition =
        topMargin + treePosition.indexInRound * totalNodeHeight;

    return verticalPosition;
  }

  /// Returns the total vertical margin of the match nodes of a given [round].
  ///
  /// That is each node has half this space in the top and bottom direction from
  /// its edges.
  double getVerticalNodeMargin(int round) {
    int relativeNodeMargin = (pow(2, round) as int) - 1;

    double absoluteNodeMargin = relativeNodeMargin * _matchNodeSize.height;

    return absoluteNodeMargin;
  }

  /// Converts the [nodePosition] to the position where the given
  /// [edge] should be placed.
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

abstract class _TournamentTreePosition {
  int get roundIndex;
  int get indexInRound;
}

class _MatchNode extends LayoutId implements _TournamentTreePosition {
  _MatchNode({
    required this.roundIndex,
    required this.indexInRound,
    required super.child,
  }) : super(id: (roundIndex, indexInRound));

  @override
  final int roundIndex;
  @override
  final int indexInRound;
}

class _TreeEdge extends LayoutId implements _TournamentTreePosition {
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
  @override
  final int roundIndex;
  @override
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
