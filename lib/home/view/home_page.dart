import 'package:ez_badminton_admin_app/assets/badminton_icons_icons.dart';
import 'package:ez_badminton_admin_app/competition_management/view/competition_list_page.dart';
import 'package:ez_badminton_admin_app/court_management/view/court_list_page.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_cubit.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_state.dart';
import 'package:ez_badminton_admin_app/home/widgets/navigation_tab.dart';
import 'package:ez_badminton_admin_app/player_management/view/player_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  late final List<GlobalKey<NavigatorState>> navigatorKeys;
  late final List<AnimationController> switchAnimationControllers;
  final int numTabs = 4;
  late List<NavigationTab> tabs;
  late List<Widget> tabViews;

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
          label: l10n.player(2),
          root: const PlayerListPage(),
          unselectedIcon: Icons.person_outline,
          selectedIcon: Icons.person,
        ),
        NavigationTab(
          index: 1,
          label: l10n.competition(2),
          root: const CompetitionListPage(),
          unselectedIcon: BadmintonIcons.badminton_rackets_crossed,
          selectedIcon: BadmintonIcons.badminton_rackets_crossed,
        ),
        NavigationTab(
          index: 2,
          label: l10n.court(2),
          root: const CourtListPage(),
          unselectedIcon: BadmintonIcons.badminton_court_with_net_outline,
          selectedIcon: BadmintonIcons.badminton_court_with_net,
        ),
        NavigationTab(
          index: 3,
          label: l10n.matches,
          root: const Placeholder(),
          unselectedIcon: BadmintonIcons.badminton_shuttlecock_outline,
          selectedIcon: BadmintonIcons.badminton_shuttlecock,
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
    return BlocProvider(
      create: (context) => TabNavigationCubit(),
      child: BlocBuilder<TabNavigationCubit, TabNavigationState>(
        builder: (context, tabNavigationState) {
          return Row(
            children: [
              NavigationRail(
                onDestinationSelected: (index) =>
                    context.read<TabNavigationCubit>().tabChanged(index),
                destinations: tabs
                    .map((tab) => NavigationRailDestination(
                          icon: FaIcon(tab.unselectedIcon),
                          selectedIcon: FaIcon(tab.selectedIcon),
                          label: Text(tab.label),
                        ))
                    .toList(),
                selectedIndex: tabNavigationState.selectedIndex,
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
                        if (index == tabNavigationState.selectedIndex) {
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
