import 'package:ez_badminton_admin_app/utils/animated_transformation_controller/animated_transformation_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ZoomButtons extends StatelessWidget {
  const ZoomButtons({
    super.key,
    required this.viewController,
    required this.maxScale,
  });

  final AnimatedTransformationController viewController;
  final double maxScale;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Tooltip(
          message: l10n.zoom,
          waitDuration: const Duration(milliseconds: 500),
          child: TextButton(
            onPressed: () => viewController.zoom(1 / 1.15),
            child: const Icon(Icons.zoom_out),
          ),
        ),
        Tooltip(
          message: l10n.resetView,
          waitDuration: const Duration(milliseconds: 500),
          child: TextButton(
            onPressed: viewController.fitToScreen,
            child: const Icon(Icons.fit_screen_rounded),
          ),
        ),
        Tooltip(
          message: l10n.zoom,
          waitDuration: const Duration(milliseconds: 500),
          child: TextButton(
            onPressed: () => viewController.zoom(
              1.15,
              maxScale: maxScale,
            ),
            child: const Icon(Icons.zoom_in),
          ),
        ),
      ],
    );
  }
}
