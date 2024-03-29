import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/tournament_mode_assignment_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/widgets/tournament_mode_settings_widget.dart';
import 'package:ez_badminton_admin_app/layout/fab_location.dart';
import 'package:ez_badminton_admin_app/widgets/progress_indicator_icon/progress_indicator_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:formz/formz.dart';

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
        competitionRepository:
            context.read<CollectionRepository<Competition>>(),
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
    return BlocConsumer<TournamentModeAssignmentCubit,
        TournamentModeAssignmentState>(
      listenWhen: (previous, current) =>
          previous.formStatus != FormzSubmissionStatus.success &&
          current.formStatus == FormzSubmissionStatus.success,
      listener: (context, state) {
        Navigator.of(context).pop();
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(l10n.assignTournamentMode)),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(right: 80, bottom: 40),
            child: FloatingActionButton.extended(
              onPressed:
                  context.read<TournamentModeAssignmentCubit>().formSubmitted,
              label: Text(l10n.save),
              icon: state.formStatus == FormzSubmissionStatus.inProgress
                  ? const ProgressIndicatorIcon()
                  : const Icon(Icons.save),
              heroTag: 'tournament_mode_assignment_save_button',
            ),
          ),
          floatingActionButtonAnimator:
              FabTranslationAnimator(speedFactor: 2.5),
          floatingActionButtonLocation: state.isDirty
              ? FloatingActionButtonLocation.endFloat
              : const EndOffscreenFabLocation(),
          body: const TournamentModeSettingsWidget(),
        );
      },
    );
  }
}
