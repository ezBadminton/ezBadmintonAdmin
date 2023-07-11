import 'package:ez_badminton_admin_app/widgets/mouse_hover_builder/mouse_hover_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MouseHoverBuilder extends StatelessWidget {
  /// A widget rebuilding upon the mouse entering or exiting
  const MouseHoverBuilder({
    super.key,
    required this.builder,
  });

  /// The builder receives the [isHovered] argument to change the build
  /// depending on the mouse hovering or not.
  final Widget Function(BuildContext context, bool isHovered) builder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MouseHoverCubit(),
      child: _MouseHoverBuilder(builder: builder),
    );
  }
}

class _MouseHoverBuilder extends StatelessWidget {
  const _MouseHoverBuilder({
    required this.builder,
  });

  final Widget Function(BuildContext context, bool isHovered) builder;

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<MouseHoverCubit>();
    return MouseRegion(
      onEnter: (_) => cubit.mouseEntered(),
      onExit: (_) => cubit.mouseExited(),
      child: BlocBuilder<MouseHoverCubit, bool>(
        builder: (context, isHovered) {
          return builder(context, isHovered);
        },
      ),
    );
  }
}
