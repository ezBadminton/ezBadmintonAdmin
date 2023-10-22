import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_cubit.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TabNavigationBackButtonBuilder extends StatelessWidget {
  const TabNavigationBackButtonBuilder({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, BackButton? backButton) builder;

  @override
  Widget build(BuildContext context) {
    var navigationCubit = context.read<TabNavigationCubit>();

    return BlocBuilder<TabNavigationCubit, TabNavigationState>(
      builder: (context, state) {
        BackButton? backButton;
        if (state.fromIndex != null) {
          backButton = BackButton(
            onPressed: () => navigationCubit.tabChanged(state.fromIndex!),
          );
        }

        return builder(context, backButton);
      },
    );
  }
}
