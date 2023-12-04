import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/result_management/widgets/result_explorer.dart';
import 'package:ez_badminton_admin_app/widgets/competition_selection_list/competition_selection_list.dart';
import 'package:ez_badminton_admin_app/widgets/competition_selection_list/cubit/competition_selection_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:ez_badminton_admin_app/widgets/tab_navigation_back_button/tab_navigation_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResultManagementPage extends StatelessWidget {
  const ResultManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CompetitionSelectionCubit(
        competitionRepository:
            context.read<CollectionRepository<Competition>>(),
      ),
      child: const _ResultManagementPageScaffold(),
    );
  }
}

class _ResultManagementPageScaffold extends StatelessWidget {
  const _ResultManagementPageScaffold();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return TabNavigationBackButtonBuilder(
      builder: (context, backButton) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.resultManagement),
          leading: backButton,
        ),
        body: BlocBuilder<CompetitionSelectionCubit, CompetitionSelectionState>(
          builder: (context, state) {
            return LoadingScreen(
              loadingStatus: state.loadingStatus,
              builder: (context) => Row(
                children: [
                  SizedBox(
                    width: 260,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: CompetitionSelectionList(
                        noCompetitionsHint: l10n.noCompetitionsResultHint,
                      ),
                    ),
                  ),
                  const VerticalDivider(
                    thickness: 1,
                    width: 1,
                    color: Colors.black26,
                  ),
                  const Expanded(
                    child: ResultExplorer(),
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
