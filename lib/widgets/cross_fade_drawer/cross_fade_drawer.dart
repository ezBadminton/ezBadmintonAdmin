import 'package:ez_badminton_admin_app/widgets/cross_fade_drawer/cross_fade_drawer_controller.dart';
import 'package:flutter/material.dart';

/// A cross fading widget that animates using an [AnimatedCrossFade]
class CrossFadeDrawer extends StatefulWidget {
  /// Creates a cross fade drawer using the given [collapsed] and [expanded]
  /// representations.
  /// It specifically works for drawers that expand to the right
  /// or to the bottom.
  ///
  /// The drawer can only be controlled by the given [controller] or by directly
  /// manipulating the state (e.g. via a GlobalKey).
  const CrossFadeDrawer({
    super.key,
    required this.collapsed,
    required this.expanded,
    this.axis = Axis.horizontal,
    CrossFadeDrawerController? controller,
  }) : _controller = controller;

  final Widget collapsed;
  final Widget expanded;

  final Axis axis;

  final CrossFadeDrawerController? _controller;

  @override
  State<CrossFadeDrawer> createState() => _CrossFadeDrawerState();
}

class _CrossFadeDrawerState extends State<CrossFadeDrawer> {
  late CrossFadeState _crossFadeState;

  CrossFadeDrawerController? get _controller => widget._controller;

  @override
  void initState() {
    if (_controller != null) {
      _controllerChanged();
      _controller!.addListener(_controllerChanged);
    } else {
      drawerChanged(true);
    }
    super.initState();
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.removeListener(_controllerChanged);
    }
    super.dispose();
  }

  void _controllerChanged() {
    if (_controller == null) {
      return;
    }
    drawerChanged(_controller!.isExpanded);
  }

  void drawerChanged(bool isExpanded) {
    setState(() {
      _crossFadeState =
          isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: widget.expanded,
      secondChild: widget.collapsed,
      crossFadeState: _crossFadeState,
      duration: const Duration(milliseconds: 150),
      sizeCurve: Curves.easeOutQuad,
      alignment: Alignment.topLeft,
      layoutBuilder: (topChild, topChildKey, bottomChild, bottomChildKey) =>
          _layoutBuilder(
        topChild,
        topChildKey,
        bottomChild,
        bottomChildKey,
        widget.axis,
      ),
    );
  }

  static Widget _layoutBuilder(
    Widget topChild,
    Key topChildKey,
    Widget bottomChild,
    Key bottomChildKey,
    Axis axis,
  ) {
    bool horizontal = axis == Axis.horizontal;

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned(
          key: bottomChildKey,
          top: horizontal ? 0.0 : null,
          bottom: horizontal ? 0.0 : null,
          left: horizontal ? null : 0.0,
          right: horizontal ? null : 0.0,
          child: bottomChild,
        ),
        Positioned(
          key: topChildKey,
          child: topChild,
        ),
      ],
    );
  }
}
