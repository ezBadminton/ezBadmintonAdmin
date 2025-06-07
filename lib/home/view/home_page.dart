import 'package:ez_badminton_admin_app/assets/badminton_icons_icons.dart';
import 'package:ez_badminton_admin_app/competition_management/view/competition_list_page.dart';
import 'package:ez_badminton_admin_app/court_management/cubit/cubit/court_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/view/court_list_page.dart';
import 'package:ez_badminton_admin_app/draw_management/view/draw_management_page.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_cubit.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_state.dart';
import 'package:ez_badminton_admin_app/home/widgets/court_navigation_tab_icon.dart';
import 'package:ez_badminton_admin_app/home/widgets/navigation_tab.dart';
import 'package:ez_badminton_admin_app/home/widgets/result_navigation_tab_icon.dart';
import 'package:ez_badminton_admin_app/match_management/cubit/match_court_assignment_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/view/match_management_page.dart';
import 'package:ez_badminton_admin_app/player_management/view/player_list_page.dart';
import 'package:ez_badminton_admin_app/result_management/view/result_management_page.dart';
import 'package:ez_badminton_admin_app/settings/view/settings_page.dart';
import 'package:ez_badminton_admin_app/tournament_plans/cubit/tournament_plan_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ez_badminton_admin_app/l10n/l10n.dart';
import 'package:model_repository/model_repository.dart';

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
  final int numTabs = 6;
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
          iconBuilder: (icon, _) => CourtNavigationTabIcon(icon: icon),
        ),
        NavigationTab(
          index: 3,
          label: l10n.draw(2),
          root: const DrawManagementPage(),
          unselectedIcon: BadmintonIcons.tournament_tree,
          selectedIcon: BadmintonIcons.tournament_tree,
        ),
        NavigationTab(
          index: 4,
          label: l10n.match(2),
          root: const MatchManagementPage(),
          unselectedIcon: BadmintonIcons.badminton_shuttlecock_outline,
          selectedIcon: BadmintonIcons.badminton_shuttlecock,
        ),
        NavigationTab(
          index: 5,
          label: l10n.result(2),
          root: const ResultManagementPage(),
          unselectedIcon: Icons.emoji_events_outlined,
          selectedIcon: Icons.emoji_events,
          iconBuilder: (icon, selected) => ResultNavigationTabIcon(
            icon: icon,
            isTabSelected: selected,
          ),
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TabNavigationCubit(),
        ),
        BlocProvider(
          create: (context) => TournamentPlanCubit(
            tournamentPlanStore: context.read<ModelStore<TournamentPlan>>(),
          ),
        ),
        BlocProvider(
          create: (context) => CourtCubit(
            courtStore: context.read<ModelStore<Court>>(),
            scheduledMatchStore: context.read<ModelStore<ScheduledMatch>>(),
            scheduledRoundStore: context.read<ModelStore<ScheduledRound>>(),
          ),
        ),
        BlocProvider(
          create: (context) => MatchCourtAssignmentCubit(
            assignEndpoint: context.read(),
            unassignEndpoint: context.read(),
          ),
        ),
      ],
      child: BlocBuilder<TabNavigationCubit, TabNavigationState>(
        builder: (context, tabNavigationState) {
          return Scaffold(
            body: SafeArea(
              top: false,
              child: ResultManagementPage(),
            ),
          );
        },
      ),
    );
  }
}
