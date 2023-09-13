import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/tournament_mode_assignment_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/widgets/tournament_mode_selector.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/widgets/tournament_mode_settings_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TournamentModeAssignmentPage extends StatelessWidget {
  const TournamentModeAssignmentPage({
    super.key,
    required this.competitions,
  });

  final List<Competition> competitions;

  static Route<void> route(List<Competition> competitions) {
    return MaterialPageRoute<void>(
      builder: (_) => TournamentModeAssignmentPage(competitions: competitions),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TournamentModeAssignmentCubit(
        competitions: competitions,
        tournamentModeSettingsRepository:
            context.read<CollectionRepository<TournamentModeSettings>>(),
      ),
      child: const _TournamentModeAssignmentPageScaffold(),
    );
  }
}

class _TournamentModeAssignmentPageScaffold extends StatelessWidget {
  const _TournamentModeAssignmentPageScaffold();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.assignTournamentMode)),
      body: const Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 600,
          child: Column(
            children: [
              SizedBox(height: 50),
              TournametModeSelector(),
              SizedBox(height: 20),
              Divider(
                height: 1,
                indent: 20,
                endIndent: 20,
                thickness: 0,
              ),
              SizedBox(height: 30),
              TournamentModeSettingsWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
