import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_cubit.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_state.dart';
import 'package:ez_badminton_admin_app/home/widgets/navigation_tab.dart';
import 'package:ez_badminton_admin_app/settings/view/hint_settings.dart';
import 'package:ez_badminton_admin_app/settings/view/info_screen_settings.dart';
import 'package:ez_badminton_admin_app/settings/view/version_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ez_badminton_admin_app/l10n/l10n.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const SettingsPage());
  }

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin<SettingsPage> {
  late final List<GlobalKey<NavigatorState>> navigatorKeys;
  late final List<AnimationController> switchAnimationControllers;
  final int numTabs = 3;
  late List<NavigationTab> tabs;
  late List<Widget> tabViews;

  AnimationController tabSwitchController() {
    final AnimationController controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    return controller;
  }

  @override
  void initState() {
    super.initState();
    navigatorKeys = List<GlobalKey<NavigatorState>>.generate(
        numTabs, (int index) => GlobalKey()).toList();
    switchAnimationControllers = List<AnimationController>.generate(
        numTabs, (int index) => tabSwitchController()).toList();
    switchAnimationControllers[0].value = 1.0;
    tabViews = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var l10n = AppLocalizations.of(context)!;
    setState(() {
      tabs = [
        NavigationTab(
          index: 0,
          label: l10n.hints,
          root: const HintSettingsPage(),
          unselectedIcon: Icons.person_outline,
          selectedIcon: Icons.person,
        ),
        NavigationTab(
          index: 1,
          label: l10n.infoscreens,
          root: const InfoScreenSettingsPage(),
          unselectedIcon: Icons.person_outline,
          selectedIcon: Icons.person,
        ),
        NavigationTab(
          index: 2,
          label: l10n.version,
          root: const VersionDisplayPage(),
          unselectedIcon: Icons.person_outline,
          selectedIcon: Icons.person,
        ),
      ];

      assert(
        tabs.length == numTabs,
        'Update numTabs to match the length of the NavigationTab list',
      );

      tabViews = tabs.map((NavigationTab tab) {
        return ClipRect(
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: switchAnimationControllers[tab.index],
              curve: Curves.fastOutSlowIn,
            )),
            child: NavigationTabView(
              tab: tab,
              navigatorKey: navigatorKeys[tab.index],
            ),
          ),
        );
      }).toList();
    });
  }

  @override
  void dispose() {
    for (final AnimationController controller in switchAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => TabNavigationCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.settings),
        ),
        body: BlocBuilder<TabNavigationCubit, TabNavigationState>(
          builder: (context, tabNavigationState) {
            return Container(
              color: Colors.white,
              child: Row(
                children: [
                  SizedBox(
                    width: 260,
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        for (final tab in tabs) ...[
                          _SettingsTabLabel(
                            label: tab.label,
                            selected:
                                tab.index == tabNavigationState.selectedIndex,
                            onTabSelected: () => context
                                .read<TabNavigationCubit>()
                                .tabChanged(tab.index),
                          ),
                        ]
                      ],
                    ),
                  ),
                  const VerticalDivider(thickness: 1, width: 1),
                  Expanded(
                    child: Scaffold(
                      body: SafeArea(
                        top: false,
                        child: Stack(
                          fit: StackFit.expand,
                          children: tabs.map((NavigationTab tab) {
                            final int index = tab.index;
                            final Widget view = tabViews[index];
                            if (index == tabNavigationState.selectedIndex) {
                              switchAnimationControllers[index].forward();
                              return Offstage(offstage: false, child: view);
                            } else {
                              switchAnimationControllers[index].reverse();
                              if (switchAnimationControllers[index]
                                  .isAnimating) {
                                return IgnorePointer(child: view);
                              }
                              return Offstage(child: view);
                            }
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SettingsTabLabel extends StatelessWidget {
  const _SettingsTabLabel({
    required this.label,
    required this.selected,
    required this.onTabSelected,
  });

  final String label;
  final bool selected;
  final void Function() onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextButton(
        onPressed: onTabSelected,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(
            Theme.of(context).primaryColor.withAlpha(selected ? 120 : 40),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 45,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 17,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
