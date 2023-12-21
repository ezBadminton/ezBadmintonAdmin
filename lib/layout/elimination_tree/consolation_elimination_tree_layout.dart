import 'dart:math';

import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:flutter/material.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/bracket_sizes.dart'
    as bracket_widths;

class ConsolationEliminationTreeLayout extends StatelessWidget {
  ConsolationEliminationTreeLayout({
    super.key,
    required this.consolationTreeRoot,
  }) : layoutSize = _getLayoutSize(consolationTreeRoot) {
    _allTreeNodes = [];
    _layoutTreeRoot = _createLayoutTree(
      node: consolationTreeRoot,
      parent: null,
      allNodes: _allTreeNodes,
    );
  }

  final ConsolationTreeNode consolationTreeRoot;

  final Size layoutSize;

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

  static Size _getLayoutSize(ConsolationTreeNode consolationTreeRoot) {
    double height = _getLayoutHeight(
      node: consolationTreeRoot,
      result: 0,
    );
    double width = _getLayoutWidth(
      node: consolationTreeRoot,
      rightHandSiblings: [],
      result: 0,
    );

    return Size(width, height);
  }

  static double _getLayoutHeight({
    required ConsolationTreeNode node,
    required double result,
  }) {
    double localResult = result + node.mainBracket.layoutSize.height;

    ConsolationTreeNode? firstChild = node.consolationBrackets.firstOrNull;

    if (firstChild != null) {
      localResult = _getLayoutHeight(node: firstChild, result: localResult);
    }

    return localResult;
  }

  static double _getLayoutWidth({
    required ConsolationTreeNode node,
    required Iterable<ConsolationTreeNode> rightHandSiblings,
    required double result,
  }) {
    double siblingWidth = result +
        node.mainBracket.layoutSize.width +
        bracket_widths.singleEliminationRoundGap;
    if (rightHandSiblings.isNotEmpty) {
      ConsolationTreeNode nextSibling = rightHandSiblings.first;
      siblingWidth = _getLayoutWidth(
        node: nextSibling,
        rightHandSiblings: rightHandSiblings.skip(1),
        result: siblingWidth,
      );
    }

    double childWidth = 0;
    if (node.consolationBrackets.isNotEmpty) {
      childWidth = _getLayoutWidth(
        node: node.consolationBrackets.first,
        rightHandSiblings: node.consolationBrackets.skip(1),
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
    positionBrackets(layoutTreeRoot, Offset.zero);
  }

  void layoutBrackets(_TreeNode node) {
    layoutChild(node.id, BoxConstraints.tight(node.bracket.layoutSize));

    for (_TreeNode child in node.children) {
      layoutBrackets(child);
    }
  }

  void positionBrackets(
    _TreeNode node,
    Offset position,
  ) {
    positionChild(node.id, position);

    double childrenVerticalPosition =
        position.dy + node.bracket.layoutSize.height;

    node.children.fold(
      position.dx,
      (siblingsHorizontalPosition, child) {
        Offset childPosition =
            Offset(siblingsHorizontalPosition, childrenVerticalPosition);

        positionBrackets(child, childPosition);

        return siblingsHorizontalPosition +
            child.bracket.layoutSize.width +
            bracket_widths.singleEliminationRoundGap;
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
