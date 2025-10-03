import 'package:ez_badminton_admin_app/list_selection/cubit/model_selection_cubit.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_editing/view/competition_editing_page.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_filter/competition_filter.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_filter/view/competition_filter.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_list_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_start_stop_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/view/competition_list.dart';
import 'package:ez_badminton_admin_app/competition_management/view/competition_selection_options.dart';
import 'package:ez_badminton_admin_app/competition_management/view/tournament_categorization_options.dart';
import 'package:ez_badminton_admin_app/predicate_filter/common_predicate_producers/agegroup_predicate_producer.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_filter_cubit.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate_producers.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ez_badminton_admin_app/l10n/l10n.dart';

import 'package:ez_badminton_admin_app/competition_management/cubit/competition_categorization_cubit.dart';

class CompetitionListPage extends StatelessWidget {
  const CompetitionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CompetitionFilterCubit(
            ageGroupRepository: context.read<ModelStore<AgeGroup>>(),
            playingLevelRepository: context.read<ModelStore<PlayingLevel>>(),
            tournamentRepository: context.read<ModelStore<TournamentEvent>>(),
            ageGroupPredicateProducer: AgeGroupPredicateProducer(),
            playingLevelPredicateProducer: PlayingLevelPredicateProducer(),
            registrationCountPredicateProducer:
                RegistrationCountPredicateProducer(),
            competitionTypePredicateProducer:
                CompetitionTypePredicateProducer(),
            genderCategoryPredicateProducer: GenderCategoryPredicateProducer(),
          ),
        ),
        BlocProvider(
          create: (context) => CompetitionCategorizationCubit(
            l10n: l10n,
            tournamentRepository: context.read<ModelStore<TournamentEvent>>(),
            competitionRepository: context.read<ModelStore<Competition>>(),
            ageGroupRepository: context.read<ModelStore<AgeGroup>>(),
            playingLevelRepository: context.read<ModelStore<PlayingLevel>>(),
          ),
        ),
        BlocProvider(
          create: CompetitionListCubit.fromContext,
        ),
        BlocProvider(
          create: (context) => ModelSelectionCubit<Competition>(
            store: context.read<ModelStore<Competition>>(),
          ),
        ),
        BlocProvider(
          create: (context) => CompetitionStartStopCubit(
            competitionRepository: context.read<ModelStore<Competition>>(),
            startEndpoint: context.read<TournamentStartEndpoint>(),
            stopEndpoint: context.read<TournamentStopEndpoint>(),
          ),
        ),
      ],
      child: const _CompetitionListPageScaffold(),
    );
  }
}

class _CompetitionListPageScaffold extends StatelessWidget {
  const _CompetitionListPageScaffold();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.competitionManagement)),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 80, bottom: 40),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(CompetitionEditingPage.route());
          },
          icon: const Icon(Icons.add),
          label: Text(l10n.add),
          heroTag: 'competition_add_button',
        ),
      ),
      body: const Align(
        alignment: AlignmentDirectional.topCenter,
        child: _CompetitionListWithControls(),
      ),
    );
  }
}

class _CompetitionListWithControls extends StatelessWidget {
  const _CompetitionListWithControls();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return BlocListener<PredicateFilterCubit<CompetitionListPage>,
        PredicateFilterState>(
      listener: (context, state) {
        final CompetitionListCubit cubit = BlocProvider.of(context);
        cubit.filterChanged(state.filters);
      },
      child: BlocBuilder<CompetitionListCubit, CompetitionListState>(
        buildWhen: (previous, current) =>
            previous.loadingStatus != current.loadingStatus,
        builder: (context, listState) {
          return BlocBuilder<CompetitionFilterCubit, CompetitionFilterState>(
            buildWhen: (previous, current) =>
                previous.loadingStatus != current.loadingStatus,
            builder: (context, filterState) {
              return BlocBuilder<ModelSelectionCubit<Competition>,
                  ModelSelectionState<Competition>>(
                builder: (context, selectionState) {
                  return LoadingScreen(
                    loadingStatus: loadingStatusConjunction(
                      [
                        listState.loadingStatus,
                        filterState.loadingStatus,
                        selectionState.loadingStatus,
                      ],
                    ),
                    errorMessage: l10n.competitionListLoadingError,
                    retryButtonLabel: l10n.retry,
                    builder: (context) => const SizedBox(
                      width: 1150,
                      child: Column(
                        children: [
                          TournamentCategorizationOptions(),
                          SizedBox(height: 12),
                          CompetitionFilter(),
                          SizedBox(height: 12),
                          CompetitionSelectionOptions(
                            optionButtons: CompetitionSelectionOptionButtons(),
                          ),
                          SizedBox(height: 25),
                          Expanded(
                            child: CompetitionList(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
