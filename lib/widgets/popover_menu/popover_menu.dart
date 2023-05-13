import 'package:ez_badminton_admin_app/widgets/popover_menu/cubit/popover_menu_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PopoverMenuButton extends StatelessWidget {
  PopoverMenuButton({
    super.key,
    required this.menu,
    required this.label,

    // Distance of the popover menu from the menu button
    this.anchorOffset = 2.0,
  });

  final Widget menu;
  final Widget label;
  final double anchorOffset;
  final _layerLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PopoverMenuCubit(),
      child: BlocBuilder<PopoverMenuCubit, PopoverMenuState>(
        buildWhen: (previous, current) => previous.menu != current.menu,
        builder: (context, state) {
          return CompositedTransformTarget(
            link: _layerLink,
            child: FilledButton(
              onPressed: () {
                state.menu.isNotEmpty
                    ? _closeMenu(context)
                    : _openMenu(
                        context, context.read<PopoverMenuCubit>(), _layerLink);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  label,
                  AnimatedRotation(
                    turns: state.menu.isNotEmpty ? -0.5 : 0.0,
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

  void _openMenu(BuildContext context, PopoverMenuCubit cubit,
      LayerLink transformFollowerLink) {
    var menuOverlay = OverlayEntry(builder: (_) {
      return BlocBuilder<PopoverMenuCubit, PopoverMenuState>(
        bloc: cubit,
        buildWhen: (previous, current) =>
            previous.opacity != current.opacity ||
            previous.scale != current.scale,
        builder: (_, state) {
          return Positioned(
            left: 0,
            top: 0,
            child: CompositedTransformFollower(
              link: transformFollowerLink,
              targetAnchor: Alignment.bottomLeft,
              followerAnchor: Alignment.topLeft,
              offset: Offset(0, anchorOffset),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 100),
                opacity: state.opacity,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 50),
                  scale: state.scale,
                  child: PopoverMenu(
                      close: () => _closeMenu(context), child: menu),
                ),
              ),
            ),
          );
        },
      );
    });
    // Cover all quadrants around the menu button with modal barriers
    var modalBarriers = [
      FollowingModalBarrier(
        cubit: cubit,
        transformFollowerLink: transformFollowerLink,
        followerAnchor: Alignment.topRight,
        targetAnchor: Alignment.topLeft,
      ),
      FollowingModalBarrier(
        cubit: cubit,
        transformFollowerLink: transformFollowerLink,
        followerAnchor: Alignment.topLeft,
        targetAnchor: Alignment.bottomLeft,
      ),
      FollowingModalBarrier(
        cubit: cubit,
        transformFollowerLink: transformFollowerLink,
        followerAnchor: Alignment.bottomLeft,
        targetAnchor: Alignment.bottomRight,
      ),
      FollowingModalBarrier(
        cubit: cubit,
        transformFollowerLink: transformFollowerLink,
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

    for (var overlay in overlays) {
      Overlay.of(context).insert(overlay);
    }
    context.read<PopoverMenuCubit>().setMenu(overlays);
    Future.delayed(const Duration(milliseconds: 10), () {
      context.read<PopoverMenuCubit>().setOpacity(1.0);
      context.read<PopoverMenuCubit>().setScale(1.0);
    });
  }

  void _closeMenu(BuildContext context) {
    context.read<PopoverMenuCubit>().setMenu([]);
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
    required this.cubit,
    required this.transformFollowerLink,
    required this.targetAnchor,
    required this.followerAnchor,
  });

  final PopoverMenuCubit cubit;
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
            onDismiss: () => cubit.setMenu([]),
          ),
        ),
      ),
    );
  }
}
