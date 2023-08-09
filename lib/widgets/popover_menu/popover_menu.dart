import 'package:ez_badminton_admin_app/widgets/popover_menu/controller/popover_menu_controller.dart';
import 'package:ez_badminton_admin_app/widgets/popover_menu/cubit/popover_menu_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PopoverMenuButton extends StatelessWidget {
  const PopoverMenuButton({
    super.key,
    required this.menu,
    required this.label,
    this.controller,

    // Distance of the popover menu from the menu button
    this.anchorOffset = 2.0,
  });

  final Widget menu;
  final Widget label;

  final PopoverMenuController? controller;

  final double anchorOffset;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PopoverMenuCubit(
        menuContent: menu,
        menuBuilder: _createMenu,
        layerLink: LayerLink(),
        controller: controller,
      ),
      child: BlocConsumer<PopoverMenuCubit, PopoverMenuState>(
        listenWhen: (previous, current) {
          if (previous.menu.isEmpty && current.menu.isNotEmpty) {
            Overlay.of(context).insertAll(current.menu);
          }
          if (previous.menu.isNotEmpty && current.menu.isEmpty) {
            for (OverlayEntry entry in previous.menu) {
              entry.remove();
            }
          }
          return false;
        },
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = context.read<PopoverMenuCubit>();
          cubit.menuContentChanged(menu);
          return CompositedTransformTarget(
            link: cubit.layerLink,
            child: FilledButton(
              onPressed: () {
                state.isMenuOpen ? cubit.closeMenu() : cubit.openMenu();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  label,
                  AnimatedRotation(
                    turns: state.isMenuOpen ? -0.5 : 0.0,
                    duration: const Duration(milliseconds: 100),
                    child: Icon(
                      Icons.keyboard_arrow_down_sharp,
                      key: UniqueKey(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<OverlayEntry> _createMenu(Widget menuContent, PopoverMenuCubit cubit) {
    var menuOverlay = OverlayEntry(builder: (_) {
      return Positioned(
        left: 0,
        top: 0,
        child: CompositedTransformFollower(
          link: cubit.layerLink,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: Offset(0, anchorOffset),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 100),
            opacity: 1.0,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 50),
              scale: 1.0,
              child: PopoverMenu(
                close: cubit.closeMenu,
                child: menuContent,
              ),
            ),
          ),
        ),
      );
    });
    // Cover all quadrants around the menu button with modal barriers
    var modalBarriers = [
      FollowingModalBarrier(
        onClose: cubit.closeMenu,
        transformFollowerLink: cubit.layerLink,
        followerAnchor: Alignment.topRight,
        targetAnchor: Alignment.topLeft,
      ),
      FollowingModalBarrier(
        onClose: cubit.closeMenu,
        transformFollowerLink: cubit.layerLink,
        followerAnchor: Alignment.topLeft,
        targetAnchor: Alignment.bottomLeft,
      ),
      FollowingModalBarrier(
        onClose: cubit.closeMenu,
        transformFollowerLink: cubit.layerLink,
        followerAnchor: Alignment.bottomLeft,
        targetAnchor: Alignment.bottomRight,
      ),
      FollowingModalBarrier(
        onClose: cubit.closeMenu,
        transformFollowerLink: cubit.layerLink,
        followerAnchor: Alignment.bottomRight,
        targetAnchor: Alignment.topRight,
      ),
    ];

    var overlays = modalBarriers
        .map(
          (barrier) => OverlayEntry(builder: (_) => barrier),
        )
        .toList();
    overlays.add(menuOverlay);

    return overlays;
  }
}

class PopoverMenu extends InheritedWidget {
  const PopoverMenu({
    super.key,
    required super.child,
    required this.close,
  });

  static PopoverMenu? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PopoverMenu>();
  }

  static PopoverMenu of(BuildContext context) {
    final PopoverMenu? result = maybeOf(context);
    assert(result != null, 'Context is not of a PopoverMenu');
    return result!;
  }

  final void Function() close;

  @override
  bool updateShouldNotify(PopoverMenu oldWidget) => false;
}

class FollowingModalBarrier extends StatelessWidget {
  const FollowingModalBarrier({
    super.key,
    required this.onClose,
    required this.transformFollowerLink,
    required this.targetAnchor,
    required this.followerAnchor,
  });

  final void Function() onClose;
  final LayerLink transformFollowerLink;
  final Alignment targetAnchor;
  final Alignment followerAnchor;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      child: CompositedTransformFollower(
        link: transformFollowerLink,
        targetAnchor: targetAnchor,
        followerAnchor: followerAnchor,
        child: ConstrainedBox(
          constraints: BoxConstraints.loose(const Size(9999, 9999)),
          child: ModalBarrier(
            onDismiss: onClose,
          ),
        ),
      ),
    );
  }
}
