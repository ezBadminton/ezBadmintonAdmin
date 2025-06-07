import 'package:ez_badminton_admin_app/result_management/widgets/result_explorer.dart';
import 'package:ez_badminton_admin_app/widgets/competition_selection_list/competition_selection_list.dart';
import 'package:ez_badminton_admin_app/widgets/competition_selection_list/cubit/competition_selection_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
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
        competitionStore: context.read(),
        tPlanStore: context.read(),
        commandRepository:
            context.read<PocketbaseRealtimeRepository<InfoscreenCommand>>(),
        cyclingInterval: const Duration(seconds: 15),
      ),
      child: const ResultManagementPageScaffold(),
    );
  }
}

class ResultManagementPageScaffold extends StatelessWidget {
  const ResultManagementPageScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: BlocBuilder<CompetitionSelectionCubit, CompetitionSelectionState>(
        builder: (context, state) {
          return LoadingScreen(
            loadingStatus: state.loadingStatus,
            builder: (context) => Row(
              children: [
                SizedBox(
                  width: 175,
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
    );
  }
}
