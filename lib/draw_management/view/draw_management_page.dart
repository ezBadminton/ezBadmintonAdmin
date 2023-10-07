import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/draw_management/cubit/competition_draw_selection_cubit.dart';
import 'package:ez_badminton_admin_app/draw_management/widgets/competition_draw_selection_list.dart';
import 'package:ez_badminton_admin_app/draw_management/widgets/draw_editor.dart';
import 'package:ez_badminton_admin_app/draw_management/widgets/entry_list.dart';
import 'package:ez_badminton_admin_app/utils/simple_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/cross_fade_drawer/cross_fade_drawer.dart';
import 'package:ez_badminton_admin_app/widgets/cross_fade_drawer/cross_fade_drawer_controller.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
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
      create: (context) => CompetitionDrawSelectionCubit(
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
    return Scaffold(
      appBar: AppBar(title: Text(l10n.drawManagement)),
      body: BlocProvider(
        create: (context) => SimpleCubit<CrossFadeDrawerController>(
          CrossFadeDrawerController(),
        ),
        child: BlocBuilder<CompetitionDrawSelectionCubit,
            CompetitionDrawSelectionState>(
          builder: (context, state) {
            CrossFadeDrawerController drawerController =
                context.read<SimpleCubit<CrossFadeDrawerController>>().state;

            return LoadingScreen(
              loadingStatus: state.loadingStatus,
              builder: (context) {
                return Row(
                  children: [
                    CrossFadeDrawer(
                      controller: drawerController,
                      collapsed: InkWell(
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
                      ),
                      expanded: Row(
                        children: [
                          const SizedBox(
                            width: 260,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: CompetitionDrawSelectionList(),
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
                      ),
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
              },
            );
          },
        ),
      ),
    );
  }
}
