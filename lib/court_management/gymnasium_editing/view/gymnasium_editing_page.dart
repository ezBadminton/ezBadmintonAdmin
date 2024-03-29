import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/cubit/gymnasium_editing_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/view/gymnasium_editing_form.dart';
import 'package:ez_badminton_admin_app/layout/fab_location.dart';
import 'package:ez_badminton_admin_app/widgets/progress_indicator_icon/progress_indicator_icon.dart';
import 'package:ez_badminton_admin_app/widgets/unsaved_changes_warning/unsaved_changes_warning.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:formz/formz.dart';

class GymnasiumEditingPage extends StatelessWidget {
  const GymnasiumEditingPage({
    super.key,
    this.gymnasium,
  });

  static Route<Gymnasium?> route([Gymnasium? gymnasium]) {
    return MaterialPageRoute<Gymnasium?>(
      builder: (_) => GymnasiumEditingPage(
        gymnasium: gymnasium,
      ),
    );
  }

  final Gymnasium? gymnasium;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    var progressCubit = context.read<TournamentProgressCubit>();

    return BlocProvider(
      create: (context) => GymnasiumEditingCubit(
        gymnasium: gymnasium,
        tournamentProgressGetter: () => progressCubit.state,
        gymnasiumRepository: context.read<CollectionRepository<Gymnasium>>(),
        courtRepository: context.read<CollectionRepository<Court>>(),
      ),
      child: BlocConsumer<GymnasiumEditingCubit, GymnasiumEditingState>(
        listenWhen: (previous, current) =>
            current.formStatus == FormzSubmissionStatus.success,
        listener: (context, state) {
          Navigator.of(context).pop(state.gymnasium);
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                gymnasium == null
                    ? l10n.addSubject(l10n.gym(1))
                    : l10n.editSubject(l10n.gym(1)),
              ),
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(right: 80, bottom: 40),
              child: FloatingActionButton.extended(
                onPressed: context.read<GymnasiumEditingCubit>().formSubmitted,
                label: Text(l10n.save),
                icon: state.formStatus == FormzSubmissionStatus.inProgress
                    ? const ProgressIndicatorIcon()
                    : const Icon(Icons.save),
                heroTag: 'gymnasium_editing_save_button',
              ),
            ),
            floatingActionButtonAnimator:
                FabTranslationAnimator(speedFactor: 2.5),
            floatingActionButtonLocation: state.isPure
                ? const EndOffscreenFabLocation()
                : FloatingActionButtonLocation.endFloat,
            body: UnsavedChangesWarning(
              formState: state,
              child: const Align(
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: GymnasiumEditingForm(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
