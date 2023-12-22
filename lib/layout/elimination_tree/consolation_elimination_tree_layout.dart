import 'dart:math';

import 'package:dart_numerics/dart_numerics.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:flutter/material.dart';
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
      parent: null,
      allNodes: _allTreeNodes,
    );
    layoutSize = _getLayoutSize(_layoutTreeRoot);
  }

  final ConsolationTreeNode consolationTreeRoot;

  late final Size layoutSize;

  late final _TreeNode _layoutTreeRoot;
  late final List<_TreeNode> _allTreeNodes;

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _ConsolationEliminationTreeLayoutDelegate(
        layoutTreeRoot: _layoutTreeRoot,
        layoutSize: layoutSize,
      ),
      children: _allTreeNodes,
    );
  }

  static _TreeNode _createLayoutTree({
    required ConsolationTreeNode node,
    required ConsolationTreeNode? parent,
    required List<_TreeNode> allNodes,
  }) {
    int tournamentSize = node.mainBracket.rounds.first.roundSize;

    List<_TreeNode> children = node.consolationBrackets
        .map(
          (child) => _createLayoutTree(
            node: child,
            parent: node,
            allNodes: allNodes,
          ),
        )
        .toList();

    _TreeNode layoutNode = _TreeNode(
      children: children,
      parent: parent,
      tournamentSize: tournamentSize,
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

    int siblingDepth = rightHandSiblings.fold(
      1,
      (maxDepth, sibling) => max(maxDepth, _getTreeDepth(sibling, 0)),
    );

    double verticalMargin =
        siblingDepth * bracket_sizes.consolationBracketVerticalMargin;

    double childrenVerticalPosition =
        position.dy + node.bracket.layoutSize.height + verticalMargin;

    node.children.fold(
      (horizontalPosition: position.dx, index: 0),
      (siblingData, child) {
        int bracketOffset = log2(
          node.tournamentSize ~/ (2 * child.tournamentSize),
        );
        // The consolation brackets are underneath the round where the losers
        // come from or to the right if other brackets already took more width.
        double minHorizontalPosition = bracketOffset *
            (node.bracket.matchNodeSize.width +
                bracket_sizes.groupKnockoutGroupGap);
        double horizontalPosition =
            max(siblingData.horizontalPosition, minHorizontalPosition);

        int siblingIndex = siblingData.index;
        int nextSiblingIndex = siblingIndex + 1;

        Offset childPosition =
            Offset(horizontalPosition, childrenVerticalPosition);

        positionBrackets(
          node: child,
          position: childPosition,
          rightHandSiblings: node.children.skip(nextSiblingIndex),
        );

        double nextSiblingHorizontalPosition = horizontalPosition +
            child.bracket.layoutSize.width +
            bracket_sizes.singleEliminationRoundGap;

        return (
          horizontalPosition: nextSiblingHorizontalPosition,
          index: nextSiblingIndex,
        );
      },
    );
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return true;
  }
}

/// The consolation tree is a tree of tournament trees.
///
/// The children of the nodes are the consolation tournaments where the losers
/// of the tournament qualify for.
class ConsolationTreeNode {
  ConsolationTreeNode({
    required this.mainBracket,
    required this.consolationBrackets,
  });

  final SingleEliminationTree mainBracket;

  final List<ConsolationTreeNode> consolationBrackets;
}

class _TreeNode extends LayoutId {
  _TreeNode({
    required this.children,
    required this.parent,
    required this.tournamentSize,
    required SingleEliminationTree child,
  }) : super(
          id: (parent, tournamentSize),
          child: child,
        );

  final List<_TreeNode> children;

  final ConsolationTreeNode? parent;
  final int tournamentSize;

  SingleEliminationTree get bracket => super.child as SingleEliminationTree;
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
