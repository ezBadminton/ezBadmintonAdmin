import 'dart:math';

import 'package:flutter/material.dart';
import 'package:notification_builder/notification_builder.dart';

/// A widget that attaches a "sticky" follower to the bottom of a vertically
/// scrollable widget.
///
/// When the scrolling or the growth of the scrollable would push the follower
/// out of view, the position of the follower becomes fixed at the bottom of
/// the parent and the scrollable continues scrolling under it.
///
/// Both widgets will be centered horizontally in the parent.
class StickyScrollableFollower extends StatelessWidget {
  const StickyScrollableFollower({
    super.key,
    required this.scrollable,
    required this.follower,
    required this.scrollController,
    this.followerOffset = 0,
    this.followerMargin = 20,
  });

  /// A widget containing a vertical scrollable with the [scrollController]
  /// as its controller.
  final Widget scrollable;

  /// The follower widget.
  final Widget follower;

  /// The [scrollController] that also has to be passed to the [scrollable].
  final ScrollController scrollController;

  /// The offset between the bottom of the scrollable and the follower.
  /// Can also be negative.
  final double followerOffset;

  /// The margin from the bottom of the parent at which the follower will
  /// become fixed.
  final double followerMargin;

  @override
  Widget build(BuildContext context) {
    return NotificationBuilder<ScrollMetricsNotification>(
      builder: (context, notification, child) {
        return ListenableBuilder(
          listenable: scrollController,
          builder: (context, child) {
            ScrollPosition? scrollPosition =
                scrollController.hasClients ? scrollController.position : null;
            return CustomMultiChildLayout(
              delegate: _StickyScrollableFollowerLayoutDelegate(
                scrollPosition: scrollPosition,
                followerOffset: followerOffset,
                followerMargin: followerMargin,
              ),
              children: [
                LayoutId(
                  id: _StickyScrollablePart.scrollable,
                  child: scrollable,
                ),
                LayoutId(
                  id: _StickyScrollablePart.follower,
                  child: follower,
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Calculates the position of the follower relative to the scrollable
class _StickyScrollableFollowerLayoutDelegate extends MultiChildLayoutDelegate {
  _StickyScrollableFollowerLayoutDelegate({
    required this.scrollPosition,
    required this.followerOffset,
    required this.followerMargin,
  });

  ScrollPosition? scrollPosition;
  final double followerOffset;
  final double followerMargin;

  @override
  void performLayout(Size size) {
    Size scrollableSize = layoutChild(
      _StickyScrollablePart.scrollable,
      BoxConstraints(
        maxHeight: size.height,
        maxWidth: size.width,
      ),
    );
    positionChild(
      _StickyScrollablePart.scrollable,
      Offset((size.width - scrollableSize.width) / 2, 0),
    );
    Size followerSize = layoutChild(
      _StickyScrollablePart.follower,
      BoxConstraints(
        maxHeight: size.height,
        maxWidth: size.width,
      ),
    );

    double scrollOverflow = scrollPosition?.maxScrollExtent ?? 0;
    double scrollOffset = scrollPosition?.pixels ?? 0;
    double scrollCorrection = scrollOverflow - scrollOffset;
    // The y-position of the bottom of the scrollable
    double scrollableEnd = max(
      0,
      scrollableSize.height + scrollCorrection,
    );

    // Position the follower under the scrollable but if the scrollable is too
    // long keep the follower above the bottom of the view
    double followerYPos = min(
      scrollableEnd + followerOffset,
      size.height - followerSize.height - followerMargin,
    );

    positionChild(
      _StickyScrollablePart.follower,
      Offset((size.width - followerSize.width) / 2, followerYPos),
    );
  }

  @override
  bool shouldRelayout(_StickyScrollableFollowerLayoutDelegate oldDelegate) {
    if (oldDelegate.scrollPosition != null && scrollPosition == null) {
      // If the scroll position gets set to null, use the old scroll position.
      // That happens when the scrollController detaches from the scrollable.
      scrollPosition = oldDelegate.scrollPosition;
    }
    return true;
  }
}

enum _StickyScrollablePart { scrollable, follower }
