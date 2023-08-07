import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_editing/view/competition_editing_page.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_selection_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/view/competition_list.dart';
import 'package:ez_badminton_admin_app/competition_management/view/competition_selection_options.dart';
import 'package:ez_badminton_admin_app/competition_management/view/tournament_categorization_options.dart';
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
          create: (context) => CompetitionSelectionCubit(),
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
        child: SizedBox(
          width: 1150,
          child: Column(
            children: [
              TournamentCategorizationOptions(),
              SizedBox(height: 12),
              CompetitionSelectionOptions(),
              SizedBox(height: 25),
              Expanded(
                child: CompetitionList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
