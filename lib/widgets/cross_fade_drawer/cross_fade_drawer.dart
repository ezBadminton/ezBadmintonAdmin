import 'package:ez_badminton_admin_app/widgets/cross_fade_drawer/cross_fade_drawer_controller.dart';
import 'package:flutter/material.dart';

/// A cross fading widget that animates like a side drawer
class CrossFadeDrawer extends StatefulWidget {
  /// Creates a cross fade drawer using the given [collapsed] and [expanded]
  /// representations.
  /// It specifically works for drawers that expand to the right.
  ///
  /// The drawer can only be controlled by the given [controller] or by directly
  /// manipulating the state (e.g. via a GlobalKey).
  const CrossFadeDrawer({
    super.key,
    required this.collapsed,
    required this.expanded,
    CrossFadeDrawerController? controller,
  }) : _controller = controller;

  final Widget collapsed;
  final Widget expanded;

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
      layoutBuilder: _layoutBuilder,
    );
  }

  static Widget _layoutBuilder(
    Widget topChild,
    Key topChildKey,
    Widget bottomChild,
    Key bottomChildKey,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned(
          key: bottomChildKey,
          top: 0.0,
          bottom: 0.0,
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
