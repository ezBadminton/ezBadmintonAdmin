import 'dart:math';

import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/utils/log2/log2.dart';
import 'package:ez_badminton_admin_app/widgets/line_painters/s_line.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/layout/elimination_tree/utils.dart'
    as utils;
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/bracket_sizes.dart'
    as bracket_sizes;
import 'package:tournament_mode/tournament_mode.dart';

class ConsolationEliminationTreeLayout extends StatelessWidget {
  ConsolationEliminationTreeLayout({
    super.key,
    required this.consolationTreeRoot,
  }) {
    _allTreeNodes = [];
    _layoutTreeRoot = _createLayoutTree(
      node: consolationTreeRoot,
      allNodes: _allTreeNodes,
    );
    _bracketLabels = _allTreeNodes
        .map((node) => node.bracketLabel)
        .whereType<_ConsolationBracketLabel>()
        .toList();
    _loserEdges = _allTreeNodes
        .map((node) => node.loserEdge)
        .whereType<_LoserEdge>()
        .toList();
    layoutSize = _getLayoutSize(_layoutTreeRoot);
  }

  final ConsolationTreeNode consolationTreeRoot;

  late final Size layoutSize;

  late final _TreeNode _layoutTreeRoot;
  late final List<_TreeNode> _allTreeNodes;

  late final List<_ConsolationBracketLabel> _bracketLabels;
  late final List<_LoserEdge> _loserEdges;

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _ConsolationEliminationTreeLayoutDelegate(
        layoutTreeRoot: _layoutTreeRoot,
        layoutSize: layoutSize,
      ),
      children: [
        ..._loserEdges,
        ..._allTreeNodes,
        ..._bracketLabels,
      ],
    );
  }

  static _TreeNode _createLayoutTree({
    required ConsolationTreeNode node,
    required List<_TreeNode> allNodes,
  }) {
    List<_TreeNode> children = node.consolationBrackets
        .map(
          (child) => _createLayoutTree(
            node: child,
            allNodes: allNodes,
          ),
        )
        .toList();

    _ConsolationBracketLabel? label;
    if (node.parent != null) {
      label = _ConsolationBracketLabel(node: node);
    }

    _LoserEdge? loserEdge;
    if (node.parent != null) {
      loserEdge = _LoserEdge(node: node);
    }

    _TreeNode layoutNode = _TreeNode(
      sourceNode: node,
      children: children,
      bracketLabel: label,
      loserEdge: loserEdge,
      child: node.treeWidget,
    );

    allNodes.add(layoutNode);

    return layoutNode;
  }

  static Size _getLayoutSize(_TreeNode layoutTreeRoot) {
    double height = _getLayoutHeight(
      node: layoutTreeRoot,
      rightHandSiblings: [],
      result: 0,
    );
    double width = _getLayoutWidth(
      node: layoutTreeRoot,
      rightHandSiblings: [],
      result: 0,
    );

    return Size(width, height);
  }

  static double _getLayoutHeight({
    required _TreeNode node,
    required Iterable<_TreeNode> rightHandSiblings,
    required double result,
  }) {
    double verticalMargin = 0;
    if (node.children.isNotEmpty) {
      int siblingDepth = rightHandSiblings.fold(
        1,
        (maxDepth, sibling) => max(maxDepth, _getTreeDepth(sibling, 0)),
      );

      verticalMargin =
          siblingDepth * bracket_sizes.consolationBracketVerticalMargin;
    }

    double localResult =
        result + node.bracket.layoutSize.height + verticalMargin;

    localResult = node.children
            .mapIndexed(
              (index, c) => _getLayoutHeight(
                node: c,
                result: localResult,
                rightHandSiblings: node.children.skip(index + 1),
              ),
            )
            .maxOrNull ??
        localResult;

    return localResult;
  }

  static double _getLayoutWidth({
    required _TreeNode node,
    required Iterable<_TreeNode> rightHandSiblings,
    required double result,
  }) {
    double horizontalMargin = 0;
    if (rightHandSiblings.isNotEmpty) {
      horizontalMargin = bracket_sizes.singleEliminationRoundGap;
    }

    double siblingWidth =
        result + node.bracket.layoutSize.width + horizontalMargin;
    if (rightHandSiblings.isNotEmpty) {
      _TreeNode nextSibling = rightHandSiblings.first;
      siblingWidth = _getLayoutWidth(
        node: nextSibling,
        rightHandSiblings: rightHandSiblings.skip(1),
        result: siblingWidth,
      );
    }

    double childWidth = 0;
    if (node.children.isNotEmpty) {
      childWidth = _getLayoutWidth(
        node: node.children.first,
        rightHandSiblings: node.children.skip(1),
        result: result,
      );
    }

    return max(childWidth, siblingWidth);
  }
}

class _ConsolationEliminationTreeLayoutDelegate
    extends MultiChildLayoutDelegate {
  _ConsolationEliminationTreeLayoutDelegate({
    required this.layoutTreeRoot,
    required this.layoutSize,
  });

  final _TreeNode layoutTreeRoot;

  final Size layoutSize;

  @override
  Size getSize(BoxConstraints constraints) => layoutSize;

  @override
  void performLayout(Size size) {
    layoutBrackets(layoutTreeRoot);
    positionBrackets(
      node: layoutTreeRoot,
      position: Offset.zero,
      rightHandSiblings: [],
    );
  }

  void layoutBrackets(_TreeNode node) {
    layoutChild(node.id, BoxConstraints.tight(node.bracket.layoutSize));
    if (node.bracketLabel != null) {
      layoutChild(node.bracketLabel!.id, const BoxConstraints());
    }

    for (_TreeNode child in node.children) {
      layoutBrackets(child);
    }
  }

  void positionBrackets({
    required _TreeNode node,
    required Offset position,
    required Iterable<_TreeNode> rightHandSiblings,
  }) {
    positionChild(node.id, position);

    if (node.bracketLabel != null) {
      Offset labelPosition = position - const Offset(0, 48);
      positionChild(node.bracketLabel!.id, labelPosition);
    }

    int tournamentSize = node.bracket.rounds.first.length;

    int siblingDepth = rightHandSiblings.fold(
      1,
      (maxDepth, sibling) => max(maxDepth, _getTreeDepth(sibling, 0)),
    );

    double verticalMargin =
        siblingDepth * bracket_sizes.consolationBracketVerticalMargin;

    double childrenVerticalPosition =
        position.dy + node.bracket.layoutSize.height + verticalMargin;

    double childHorizontalPosition = position.dx;
    for ((int, _TreeNode) childEntry in node.children.indexed) {
      _TreeNode child = childEntry.$2;
      int childIndex = childEntry.$1;

      int childTournamentSize = child.bracket.rounds.first.length;

      int bracketOffset = log2(tournamentSize ~/ (2 * childTournamentSize));
      // The consolation brackets are underneath the round where the losers
      // come from or to the right if other brackets already took more width.
      double minHorizontalPosition = bracketOffset *
          (node.bracket.matchNodeSize.width +
              bracket_sizes.singleEliminationRoundGap);
      double horizontalPosition =
          max(childHorizontalPosition, minHorizontalPosition);

      Offset childPosition =
          Offset(horizontalPosition, childrenVerticalPosition);

      positionBrackets(
        node: child,
        position: childPosition,
        rightHandSiblings: node.children.skip(childIndex + 1),
      );

      layoutAndPositionLoserEdge(
        node: child,
        nodePosition: childPosition,
        parentPosition: position,
      );

      double nextSiblingHorizontalPosition = horizontalPosition +
          child.bracket.layoutSize.width +
          bracket_sizes.singleEliminationRoundGap;

      childHorizontalPosition = nextSiblingHorizontalPosition;
    }
  }

  /// Draws the loser edge so it connects the [node] with the round in its
  /// parent where the losers come from.
  void layoutAndPositionLoserEdge({
    required _TreeNode node,
    required Offset nodePosition,
    required Offset parentPosition,
  }) {
    Size nodeSize = node.bracket.matchNodeSize;

    int bracketSize = node.bracket.rounds.first.length;
    int parentBracketSize =
        node.sourceNode.parent!.treeWidget.rounds.first.length;

    // The round from where the losers for this consolation bracket come from
    int parentRoundIndex = log2(parentBracketSize ~/ bracketSize) - 1;

    double horizontalEndPositionOffset = 0.5 * nodeSize.width +
        parentRoundIndex *
            (nodeSize.width + bracket_sizes.singleEliminationRoundGap);

    Size parentSize = node.sourceNode.parent!.treeWidget.layoutSize;

    double parentVerticalMargin =
        utils.getVerticalNodeMargin(parentRoundIndex, nodeSize.height);

    // Position on the node
    Offset startPosition = nodePosition + Offset(0.5 * nodeSize.width, 0);

    // Position at the parent round
    Offset endPosition = parentPosition +
        Offset(horizontalEndPositionOffset,
            parentSize.height - 0.5 * parentVerticalMargin);

    Rect loserEdgeRect = Rect.fromPoints(startPosition, endPosition);

    layoutChild(node.loserEdge!.id, BoxConstraints.tight(loserEdgeRect.size));
    positionChild(node.loserEdge!.id, loserEdgeRect.topLeft);
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return true;
  }
}

/// The consolation tree is a tree of [SingleEliminationTree]s.
///
/// The children of the nodes are the consolation tournaments where the losers
/// of the main bracket qualify for.
class ConsolationTreeNode {
  ConsolationTreeNode({
    required this.bracket,
    required this.treeWidget,
    required this.consolationBrackets,
  });

  final BracketWithConsolation bracket;

  final SingleEliminationTree treeWidget;

  ConsolationTreeNode? parent;
  final List<ConsolationTreeNode> consolationBrackets;
}

/// A wrapper node for [ConsolationTreeNode] that identifies it to the
/// layout delegate and holds the bracket label and loser edge widgets.
class _TreeNode extends LayoutId {
  _TreeNode({
    required this.sourceNode,
    required this.children,
    required SingleEliminationTree child,
    required this.bracketLabel,
    required this.loserEdge,
  }) : super(
          id: sourceNode,
          child: child,
        );

  final ConsolationTreeNode sourceNode;

  final List<_TreeNode> children;

  final _ConsolationBracketLabel? bracketLabel;

  final _LoserEdge? loserEdge;

  SingleEliminationTree get bracket => super.child as SingleEliminationTree;
}

class _ConsolationBracketLabel extends LayoutId {
  _ConsolationBracketLabel({
    required ConsolationTreeNode node,
  }) : super(
          id: ('bracketLabel', node),
          child: _buildPlacementText(node),
        );

  static _PlacementText _buildPlacementText(ConsolationTreeNode node) {
    (int, int) rankRange = node.bracket.getRankRange();

    return _PlacementText(
      upperBound: rankRange.$1 + 1,
      lowerBound: rankRange.$2 + 1,
    );
  }
}

class _PlacementText extends StatelessWidget {
  const _PlacementText({
    required this.upperBound,
    required this.lowerBound,
  });

  final int upperBound;
  final int lowerBound;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    TextStyle style = const TextStyle(fontSize: 32);

    if (upperBound == 3 && lowerBound == 4) {
      return Text(
        l10n.matchForThrid,
        style: style,
      );
    }

    return Text(
      l10n.upperToLowerRank(lowerBound, upperBound),
      style: style,
    );
  }
}

class _LoserEdge extends LayoutId {
  _LoserEdge({
    required this.node,
  }) : super(
          child: const SLine(color: Colors.black26),
          id: ('loserEdge', node),
        );

  final ConsolationTreeNode node;
}

int _getTreeDepth(_TreeNode node, int depth) {
  int localDepth = depth + 1;

  int deepestChild = node.children.fold(
    localDepth,
    (deepestDepth, child) => max(
      deepestDepth,
      _getTreeDepth(child, localDepth),
    ),
  );

  return deepestChild;
}
