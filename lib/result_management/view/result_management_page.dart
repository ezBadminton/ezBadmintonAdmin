import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/widgets/competition_selection_list/competition_selection_list.dart';
import 'package:ez_badminton_admin_app/widgets/competition_selection_list/cubit/competition_selection_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.resultManagement)),
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
                const Expanded(child: Placeholder()),
              ],
            ),
          );
        },
      ),
    );
  }
}
