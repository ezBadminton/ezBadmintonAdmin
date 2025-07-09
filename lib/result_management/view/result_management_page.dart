import 'package:ez_badminton_admin_app/result_management/cubit/infoscreen_control_qr_cubit.dart';
import 'package:ez_badminton_admin_app/result_management/widgets/result_explorer.dart';
import 'package:ez_badminton_admin_app/widgets/competition_selection_list/competition_selection_list.dart';
import 'package:ez_badminton_admin_app/widgets/competition_selection_list/cubit/competition_selection_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ez_badminton_admin_app/l10n/l10n.dart';
import 'package:model_repository/model_repository.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ResultManagementPage extends StatelessWidget {
  const ResultManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => CompetitionSelectionCubit(
        competitionStore: context.read(),
        tPlanStore: context.read(),
        infoscreenUserStore: context.read(),
        commandRepository:
            context.read<PocketbaseRealtimeRepository<InfoscreenCommand>>(),
        l10n: l10n,
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
                Column(
                  children: [
                    const Expanded(child: SizedBox()),
                    SizedBox(
                      width: 175,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: CompetitionSelectionList(
                          noCompetitionsHint: l10n.noCompetitionsResultHint,
                        ),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    ControlQrCode(),
                  ],
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

class ControlQrCode extends StatelessWidget {
  const ControlQrCode({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => InfoscreenControlQrCubit(
        infoscreenUserStore: context.read(),
      ),
      child: BlocBuilder<InfoscreenControlQrCubit, InfoscreenControlQrState>(
        builder: (context, state) {
          return Container(
            color: Theme.of(context).colorScheme.primary,
            width: 175,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  l10n.controlMe,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  color: Colors.grey.shade300,
                  child: QrImageView(
                    data: state.controllerURL,
                    size: 116,
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}
