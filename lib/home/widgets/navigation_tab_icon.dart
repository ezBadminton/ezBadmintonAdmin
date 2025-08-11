import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// The icon for the result tab.
///
/// It can show a notification warning the user of unbroken ties that are
/// blocking the tournament progress.
class NavigationTabIcon extends StatefulWidget {
  const NavigationTabIcon({
    super.key,
    required this.icon,
    this.notificationIcon,
    this.notification,
    this.onNotificationOutsideClicked,
  });

  /// Icon that represents this tab
  final IconData icon;

  /// A secondary icon that indicates an active notification for this tab
  final Widget? notificationIcon;

  /// Widget that will be overlayed and aligned with the
  final Widget? notification;

  /// Callback for when anywhere outside the notification widget is clicked
  /// while the [notification] is set
  final VoidCallback? onNotificationOutsideClicked;

  @override
  State<NavigationTabIcon> createState() => _NavigationTabIconState();
}

class _NavigationTabIconState extends State<NavigationTabIcon> {
  final LayerLink layerLink = LayerLink();
  OverlayEntry? notification;
  OverlayEntry? notificationIcon;

  @override
  void didUpdateWidget(NavigationTabIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.notificationIcon != widget.notificationIcon) {
      hideNotificationIcon();
      if (widget.notificationIcon != null) {
        showNotificationIcon();
      }
    }

    if (oldWidget.notification != widget.notification) {
      hideNotification();
      if (widget.notification != null) {
        showNotfication();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: layerLink,
      child: FaIcon(widget.icon),
    );
  }

  @override
  void dispose() {
    super.dispose();
    hideNotification();
    hideNotificationIcon();
  }

  void showNotfication() {
    if (notification == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          notification = _buildNotificationOverlay();
          Overlay.of(context).insert(notification!);
        },
      );
    }
  }

  void hideNotification() {
    notification?.remove();
    notification = null;
  }

  void showNotificationIcon() {
    if (notificationIcon == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          notificationIcon = _buildNotificationIconOverlay();
          Overlay.of(context).insert(notificationIcon!);
        },
      );
    }
  }

  void hideNotificationIcon() {
    notificationIcon?.remove();
    notificationIcon = null;
  }

  OverlayEntry _buildNotificationOverlay() {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Center(
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (_) => widget.onNotificationOutsideClicked?.call(),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.topStart,
            child: DefaultTextStyle(
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              child: CompositedTransformFollower(
                link: layerLink,
                followerAnchor: Alignment.centerLeft,
                targetAnchor: Alignment.center,
                offset: const Offset(32, 0),
                child: widget.notification,
              ),
            ),
          ),
        ],
      ),
    );
  }

  OverlayEntry _buildNotificationIconOverlay() {
    return OverlayEntry(
      builder: (context) => Align(
        alignment: AlignmentDirectional.topStart,
        child: CompositedTransformFollower(
          link: layerLink,
          followerAnchor: Alignment.center,
          targetAnchor: Alignment.center,
          offset: const Offset(15, 8),
          child: widget.notificationIcon,
        ),
      ),
    );
  }
}
