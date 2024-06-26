import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/draw_management/plan_printing/view/plan_printing_page.dart';
import 'package:ez_badminton_admin_app/widgets/competition_selection_list/competition_selection_list.dart';
import 'package:ez_badminton_admin_app/draw_management/widgets/draw_editor.dart';
import 'package:ez_badminton_admin_app/draw_management/widgets/entry_list.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_cubit.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_state.dart';
import 'package:ez_badminton_admin_app/utils/simple_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/competition_selection_list/cubit/competition_selection_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/cross_fade_drawer/cross_fade_drawer.dart';
import 'package:ez_badminton_admin_app/widgets/cross_fade_drawer/cross_fade_drawer_controller.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:ez_badminton_admin_app/widgets/tab_navigation_back_button/tab_navigation_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DrawManagementPage extends StatelessWidget {
  const DrawManagementPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CompetitionSelectionCubit(
        competitionRepository:
            context.read<CollectionRepository<Competition>>(),
      ),
      child: const _DrawManagementPageScaffold(),
    );
  }
}

class _DrawManagementPageScaffold extends StatelessWidget {
  const _DrawManagementPageScaffold();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return TabNavigationBackButtonBuilder(
      builder: (context, backButton) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.drawManagement),
          leading: backButton,
        ),
        body: BlocListener<TabNavigationCubit, TabNavigationState>(
          listenWhen: (previous, current) =>
              current.selectedIndex == 3 &&
              current.tabChangeReason is Competition,
          listener: (context, state) {
            var cubit = context.read<CompetitionSelectionCubit>();
            cubit.competitionSelected(state.tabChangeReason as Competition);
          },
          child: BlocProvider(
            create: (context) => SimpleCubit<CrossFadeDrawerController>(
              CrossFadeDrawerController(),
            ),
            child: BlocBuilder<CompetitionSelectionCubit,
                CompetitionSelectionState>(
              buildWhen: (previous, current) =>
                  previous.loadingStatus != current.loadingStatus,
              builder: (context, state) => LoadingScreen(
                loadingStatus: state.loadingStatus,
                builder: (context) => const _DrawManagementPanels(),
              ),
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(right: 80, bottom: 40),
          child:
              BlocBuilder<CompetitionSelectionCubit, CompetitionSelectionState>(
            builder: (context, state) {
              return FloatingActionButton(
                onPressed: () {
                  Competition? initiallySelectedForPrint =
                      state.selectedCompetition.value;
                  if (initiallySelectedForPrint != null &&
                      initiallySelectedForPrint.draw.isEmpty) {
                    initiallySelectedForPrint = null;
                  }
                  Navigator.of(context).push(PlanPrintingPage.route(
                    initiallySelectedForPrint,
                  ));
                },
                child: const Icon(Icons.print),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// The [_DrawSelectionPanels] and the [DrawEditor] showing the selected
/// competition's draw. The [_DrawSelectionPanels] can be collapsed to give more
/// space to the [DrawEditor].
class _DrawManagementPanels extends StatelessWidget {
  const _DrawManagementPanels();

  @override
  Widget build(BuildContext context) {
    CrossFadeDrawerController drawerController =
        context.read<SimpleCubit<CrossFadeDrawerController>>().state;

    return Row(
      children: [
        CrossFadeDrawer(
          controller: drawerController,
          collapsed: _CollapsedDrawSelectionPanels(
            drawerController: drawerController,
          ),
          expanded: _DrawSelectionPanels(drawerController: drawerController),
        ),
        const VerticalDivider(
          thickness: 1,
          width: 1,
          color: Colors.black26,
        ),
        const Expanded(
          child: DrawEditor(),
        ),
      ],
    );
  }
}

/// Two panels containing a selection list for the competition to make the draw
/// for and the selected competition's [EntryList].
class _DrawSelectionPanels extends StatelessWidget {
  const _DrawSelectionPanels({
    required this.drawerController,
  });

  final CrossFadeDrawerController drawerController;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BlocBuilder<CompetitionSelectionCubit, CompetitionSelectionState>(
      builder: (context, state) {
        return Row(
          children: [
            SizedBox(
              width: 260,
              child: Align(
                alignment: Alignment.topCenter,
                child: CompetitionSelectionList(
                  noCompetitionsHint: l10n.noCompetitionsDrawHint,
                ),
              ),
            ),
            const VerticalDivider(
              thickness: 1,
              width: 1,
              color: Colors.black26,
            ),
            if (state.selectedCompetition.value != null)
              SizedBox(
                width: 400,
                child: EntryList(
                  drawerController: drawerController,
                  competition: state.selectedCompetition.value!,
                ),
              )
            else
              const SizedBox(width: 400),
          ],
        );
      },
    );
  }
}

class _CollapsedDrawSelectionPanels extends StatelessWidget {
  const _CollapsedDrawSelectionPanels({
    required this.drawerController,
  });

  final CrossFadeDrawerController drawerController;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: drawerController.expand,
      child: Center(
        child: Tooltip(
          message: l10n.expand,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: Icon(
              Icons.keyboard_double_arrow_right,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
