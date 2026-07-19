import 'package:ez_badminton_admin_app/result_management/certificate_printing/view/certificate_printing_page.dart';
import 'package:ez_badminton_admin_app/result_management/widgets/result_explorer.dart';
import 'package:ez_badminton_admin_app/widgets/competition_selection_list/competition_selection_list.dart';
import 'package:ez_badminton_admin_app/widgets/competition_selection_list/cubit/competition_selection_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:ez_badminton_admin_app/widgets/tab_navigation_back_button/tab_navigation_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ez_badminton_admin_app/l10n/l10n.dart';
import 'package:model_repository/model_repository.dart';

class ResultManagementPage extends StatelessWidget {
  const ResultManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CompetitionSelectionCubit(
        competitionStore: context.read<ModelStore<Competition>>(),
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
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(right: 80, bottom: 40),
          child: BlocBuilder<CompetitionSelectionCubit,
              CompetitionSelectionState>(
            builder: (context, state) {
              return FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(CertificatePrintingPage.route(
                    state.selectedCompetition.value,
                  ));
                },
                tooltip: l10n.certificatePrinting,
                heroTag: 'certificate_printing_button',
                child: const Icon(Icons.workspace_premium),
              );
            },
          ),
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
