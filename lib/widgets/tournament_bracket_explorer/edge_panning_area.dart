import 'package:ez_badminton_admin_app/utils/animated_transformation_controller/animated_transformation_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A pointer listener that pans the given [AnimatedTransformationController]
/// when the pointer is near its edge while being pressed down.
///
/// The panning will stop when the pointer moves away from the edge or
/// stops being pressed.
///
/// This is useful for panning an [InteractiveViewer] while dragging a draggable
/// item. If the desired drag target is out of view the edge panning can move it
/// in.
class EdgePanningArea extends StatefulWidget {
  const EdgePanningArea({
    super.key,
    required this.transformationController,
    this.panSpeed = 5.0,
    this.panEdges = const EdgeInsets.all(30),
    this.panScaleCurve = Curves.linear,
    this.enabled = true,
    required this.child,
  });

  /// The [AnimatedTransformationController] of the view to be panned
  final AnimatedTransformationController transformationController;

  /// The base panning speed
  final double panSpeed;

  /// The thickness of the edges that trigger the pan when the pointer enters.
  final EdgeInsets panEdges;

  /// The [panSpeed] will be scaled depending on how far the pointer is from
  /// an edge.
  ///
  /// By default the scaling is [Curves.linear]. That means when the pointer is
  /// just inside the [panEdges] the panning will be very slow and when the
  /// pointer moves to the outside edge it will steadily rise to [panSpeed].
  ///
  /// When the pointer leaves the [child] the panning will plateau at [panSpeed].
  final Curve panScaleCurve;

  /// Set this to false to disable edge panning.
  ///
  /// This is useful e.g. when you only want edge panning while a draggable
  /// is on the pointer.
  final bool enabled;

  final Widget child;

  @override
  State<EdgePanningArea> createState() => _EdgePanningAreaState();
}

class _EdgePanningAreaState extends State<EdgePanningArea> {
  EdgeInsets _panScales = EdgeInsets.zero;

  void _setPanScales(EdgeInsets panScales) {
    bool beginPanLoop = _panScales.collapsedSize == Size.zero &&
        panScales.collapsedSize != Size.zero;

    _panScales = panScales;

    if (beginPanLoop) {
      _panLoop();
    }
  }

  void _panLoop() {
    if (_panScales.collapsedSize != Size.zero && widget.enabled) {
      _doPan();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _panLoop();
      });
    }
  }

  void _doPan() {
    if (_panScales.right > 0) {
      widget.transformationController
          .pan(Offset(widget.panSpeed * _panScales.right, 0));
    }
    if (_panScales.left > 0) {
      widget.transformationController
          .pan(Offset(-widget.panSpeed * _panScales.left, 0));
    }
    if (_panScales.bottom > 0) {
      widget.transformationController
          .pan(Offset(0, widget.panSpeed * _panScales.bottom));
    }
    if (_panScales.top > 0) {
      widget.transformationController
          .pan(Offset(0, -widget.panSpeed * _panScales.top));
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    RenderBox? viewBox = context.findRenderObject() as RenderBox?;

    if (viewBox == null) {
      return;
    }

    Size viewSize = viewBox.size;

    Offset pointerPos = event.localPosition;

    EdgeInsets edgeDistances = EdgeInsets.fromLTRB(
      pointerPos.dx,
      pointerPos.dy,
      viewSize.width - pointerPos.dx,
      viewSize.height - pointerPos.dy,
    );

    _setPanScales(EdgeInsets.fromLTRB(
      _edgeDistanceToPanScale(edgeDistances.left, widget.panEdges.left),
      _edgeDistanceToPanScale(edgeDistances.top, widget.panEdges.top),
      _edgeDistanceToPanScale(edgeDistances.right, widget.panEdges.right),
      _edgeDistanceToPanScale(edgeDistances.bottom, widget.panEdges.bottom),
    ));
  }

  void _onPointerExit() {
    _setPanScales(EdgeInsets.zero);
  }

  double _edgeDistanceToPanScale(
    double edgeDistance,
    double panEdgeThickness,
  ) {
    double panEdgeDistance = -1 * (edgeDistance - panEdgeThickness);

    double linearPanScale =
        clampDouble(panEdgeDistance / panEdgeThickness, 0.0, 1.0);

    return widget.panScaleCurve.transform(linearPanScale);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerMove: _onPointerMove,
      onPointerUp: (_) => _onPointerExit(),
      child: widget.child,
    );
  }
}
