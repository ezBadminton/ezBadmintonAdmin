import 'dart:math';

import 'package:dart_numerics/dart_numerics.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/bracket_sizes.dart'
    as bracket_sizes;

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
    layoutSize = _getLayoutSize(_layoutTreeRoot);
  }

  final ConsolationTreeNode consolationTreeRoot;

  late final Size layoutSize;

  late final _TreeNode _layoutTreeRoot;
  late final List<_TreeNode> _allTreeNodes;

  late final List<_ConsolationBracketLabel> _bracketLabels;

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _ConsolationEliminationTreeLayoutDelegate(
        layoutTreeRoot: _layoutTreeRoot,
        layoutSize: layoutSize,
      ),
      children: [
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

    _TreeNode layoutNode = _TreeNode(
      node: node,
      children: children,
      bracketLabel: label,
      child: node.mainBracket,
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

    _TreeNode? firstChild = node.children.firstOrNull;

    if (firstChild != null) {
      localResult = _getLayoutHeight(
        node: firstChild,
        result: localResult,
        rightHandSiblings: node.children.skip(1),
      );
    }

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
              bracket_sizes.groupKnockoutGroupGap);
      double horizontalPosition =
          max(childHorizontalPosition, minHorizontalPosition);

      Offset childPosition =
          Offset(horizontalPosition, childrenVerticalPosition);

      positionBrackets(
        node: child,
        position: childPosition,
        rightHandSiblings: node.children.skip(childIndex + 1),
      );

      double nextSiblingHorizontalPosition = horizontalPosition +
          child.bracket.layoutSize.width +
          bracket_sizes.singleEliminationRoundGap;

      childHorizontalPosition = nextSiblingHorizontalPosition;
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return true;
  }
}

/// The consolation tree is a tree of tournament trees.
///
/// The children of the nodes are the consolation tournaments where the losers
/// of the main bracket qualify for.
class ConsolationTreeNode {
  ConsolationTreeNode({
    required this.mainBracket,
    required this.consolationBrackets,
  });

  final SingleEliminationTree mainBracket;

  ConsolationTreeNode? parent;
  final List<ConsolationTreeNode> consolationBrackets;

  /// Returns the best rank that is attainable in this consolation bracket
  int getBestRank() {
    int bestRank = 0;
    ConsolationTreeNode currentNode = this;
    while (currentNode.parent != null) {
      bestRank += currentNode.mainBracket.rounds.first.length * 2;
      currentNode = currentNode.parent!;
    }

    return bestRank;
  }
}

class _TreeNode extends LayoutId {
  _TreeNode({
    required this.node,
    required this.children,
    required SingleEliminationTree child,
    required this.bracketLabel,
  }) : super(
          id: node,
          child: child,
        );

  final ConsolationTreeNode node;

  final List<_TreeNode> children;

  final _ConsolationBracketLabel? bracketLabel;

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
    int bracketSize = node.mainBracket.rounds.first.length;

    int upperBound = node.getBestRank();
    int lowerBound = upperBound + 2 * bracketSize;

    return _PlacementText(upperBound: upperBound + 1, lowerBound: lowerBound);
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
