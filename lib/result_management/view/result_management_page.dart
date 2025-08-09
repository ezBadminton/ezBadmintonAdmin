import 'package:ez_badminton_admin_app/competition_management/view/competition_list_page.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_filter_cubit.dart';
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
    final PredicateFilterCubit<CompetitionListPage> filterCubit =
        BlocProvider.of(context);
    return BlocProvider(
      create: (context) => CompetitionSelectionCubit(
        competitionStore: context.read<ModelStore<Competition>>(),
        filterPredicate: filterCubit.state.filters[Competition],
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
    final CompetitionSelectionCubit cubit = BlocProvider.of(context);

    return TabNavigationBackButtonBuilder(
      builder: (context, backButton) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.resultManagement),
          leading: backButton,
        ),
        body: BlocListener<PredicateFilterCubit<CompetitionListPage>,
            PredicateFilterState>(
          listener: (context, state) {
            cubit.filterChanged(state.filters[Competition]);
          },
          child:
              BlocBuilder<CompetitionSelectionCubit, CompetitionSelectionState>(
            buildWhen: (previous, current) {
              return previous.loadingStatus != current.loadingStatus;
            },
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
      ),
    );
  }
}
