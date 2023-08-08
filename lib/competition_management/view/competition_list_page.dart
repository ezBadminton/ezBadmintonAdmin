import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_editing/view/competition_editing_page.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_filter/competition_filter.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_filter/view/competition_filter.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_list_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_selection_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/view/competition_list.dart';
import 'package:ez_badminton_admin_app/competition_management/view/competition_selection_options.dart';
import 'package:ez_badminton_admin_app/competition_management/view/tournament_categorization_options.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_filter_cubit.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate_producers.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:ez_badminton_admin_app/competition_management/cubit/competition_categorization_cubit.dart';

class CompetitionListPage extends StatelessWidget {
  const CompetitionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => PredicateFilterCubit()),
        BlocProvider(
          create: (context) => CompetitionFilterCubit(
            ageGroupRepository: context.read<CollectionRepository<AgeGroup>>(),
            playingLevelRepository:
                context.read<CollectionRepository<PlayingLevel>>(),
            tournamentRepository:
                context.read<CollectionRepository<Tournament>>(),
            ageGroupPredicateProducer: AgeGroupPredicateProducer(),
            playingLevelPredicateProducer:
                PlayingLevelPredicateProducer<Competition>(),
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
            tournamentRepository:
                context.read<CollectionRepository<Tournament>>(),
            competitionRepository:
                context.read<CollectionRepository<Competition>>(),
            ageGroupRepository: context.read<CollectionRepository<AgeGroup>>(),
            playingLevelRepository:
                context.read<CollectionRepository<PlayingLevel>>(),
            teamRepository: context.read<CollectionRepository<Team>>(),
          ),
        ),
        BlocProvider(
          create: (context) => CompetitionListCubit(
            competitionRepository:
                context.read<CollectionRepository<Competition>>(),
            tournamentRepository:
                context.read<CollectionRepository<Tournament>>(),
            ageGroupRepository: context.read<CollectionRepository<AgeGroup>>(),
            playingLevelRepository:
                context.read<CollectionRepository<PlayingLevel>>(),
          ),
        ),
        BlocProvider(
          create: (context) => CompetitionSelectionCubit(
            competitionRepository:
                context.read<CollectionRepository<Competition>>(),
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
    return BlocListener<PredicateFilterCubit, PredicateFilterState>(
      listener: (context, state) {
        context.read<CompetitionListCubit>().filterChanged(state.filters);
      },
      child: BlocBuilder<CompetitionListCubit, CompetitionListState>(
        buildWhen: (previous, current) =>
            previous.loadingStatus != current.loadingStatus,
        builder: (context, listState) {
          return BlocBuilder<CompetitionFilterCubit, CompetitionFilterState>(
            buildWhen: (previous, current) =>
                previous.loadingStatus != current.loadingStatus,
            builder: (context, filterState) {
              return BlocBuilder<CompetitionSelectionCubit,
                  CompetitionSelectionState>(
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
                    onRetry: () {
                      if (listState.loadingStatus == LoadingStatus.failed) {
                        context.read<CompetitionListCubit>().loadCollections();
                      }
                      if (filterState.loadingStatus == LoadingStatus.failed) {
                        context
                            .read<CompetitionFilterCubit>()
                            .loadCollections();
                      }
                      if (selectionState.loadingStatus ==
                          LoadingStatus.failed) {
                        context
                            .read<CompetitionSelectionCubit>()
                            .loadCollections();
                      }
                    },
                    builder: (context) => const SizedBox(
                      width: 1150,
                      child: Column(
                        children: [
                          TournamentCategorizationOptions(),
                          SizedBox(height: 12),
                          CompetitionFilter(),
                          SizedBox(height: 12),
                          CompetitionSelectionOptions(),
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
