import 'package:ez_badminton_admin_app/assets/badminton_icons_icons.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_cubit.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_state.dart';
import 'package:ez_badminton_admin_app/home/widgets/navigation_tab.dart';
import 'package:ez_badminton_admin_app/player_management/view/player_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const HomePage());
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin<HomePage> {
  static List<NavigationTab> tabs = const [
    NavigationTab(
      index: 0,
      label: 'Spieler',
      root: PlayerListPage(),
      unselectedIcon: Icons.person_outline,
      selectedIcon: Icons.person,
    ),
    NavigationTab(
      index: 1,
      label: 'Disziplinen',
      root: Placeholder(),
      unselectedIcon: BadmintonIcons.badminton_rackets_crossed,
      selectedIcon: BadmintonIcons.badminton_rackets_crossed,
    ),
    NavigationTab(
      index: 2,
      label: 'Felder',
      root: Placeholder(),
      unselectedIcon: BadmintonIcons.badminton_court_outline,
      selectedIcon: BadmintonIcons.badminton_court,
    ),
    NavigationTab(
      index: 3,
      label: 'Spiele',
      root: Placeholder(),
      unselectedIcon: BadmintonIcons.badminton_shuttlecock_outline,
      selectedIcon: BadmintonIcons.badminton_shuttlecock,
    ),
  ];

  late final List<GlobalKey<NavigatorState>> navigatorKeys;
  late final List<AnimationController> switchAnimationControllers;
  late final List<Widget> tabViews;

  AnimationController tabSwitchController() {
    final AnimationController controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.dismissed) {
        setState(() {});
      }
    });
    return controller;
  }

  @override
  void initState() {
    super.initState();
    navigatorKeys = List<GlobalKey<NavigatorState>>.generate(
        tabs.length, (int index) => GlobalKey()).toList();
    switchAnimationControllers = List<AnimationController>.generate(
        tabs.length, (int index) => tabSwitchController()).toList();
    switchAnimationControllers[0].value = 1.0;
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
    return BlocProvider(
      create: (context) => TabNavigationCubit(tabs),
      child: BlocBuilder<TabNavigationCubit, TabNavigationState>(
        builder: (context, state) {
          return Row(
            children: [
              NavigationRail(
                onDestinationSelected: (index) =>
                    context.read<TabNavigationCubit>().tabChanged(index),
                destinations: tabs
                    .map((tab) => NavigationRailDestination(
                          icon: Icon(tab.unselectedIcon),
                          selectedIcon: Icon(tab.selectedIcon),
                          label: Text(tab.label),
                        ))
                    .toList(),
                selectedIndex: state.selectedIndex,
                backgroundColor: Theme.of(context).drawerTheme.backgroundColor,
                minWidth: 100,
                labelType: NavigationRailLabelType.all,
                useIndicator: true,
                indicatorColor:
                    Theme.of(context).colorScheme.primary.withAlpha(100),
                selectedLabelTextStyle: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontWeight: FontWeight.bold),
                unselectedLabelTextStyle: const TextStyle(
                  color: Colors.black87,
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
                        if (index == state.selectedIndex) {
                          switchAnimationControllers[index].forward();
                          return Offstage(offstage: false, child: view);
                        } else {
                          switchAnimationControllers[index].reverse();
                          if (switchAnimationControllers[index].isAnimating) {
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
          );
        },
      ),
    );
  }
}
