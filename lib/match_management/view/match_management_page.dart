import 'package:ez_badminton_admin_app/match_management/widgets/round_queue/round_queue_list.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_context/tournament_context.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/match_management/cubit/match_start_stop_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/cubit/match_queue_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/cubit/match_queue_settings_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/widgets/call_out_script.dart';
import 'package:ez_badminton_admin_app/match_management/widgets/match_queue_list.dart';
import 'package:ez_badminton_admin_app/match_management/widgets/queued_match.dart';
import 'package:ez_badminton_admin_app/match_management/game_sheet_printing/view/game_sheet_printing_page.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/dialog_listener.dart';
import 'package:ez_badminton_admin_app/widgets/dialogs/confirm_dialog.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MatchManagementPage extends StatelessWidget {
  const MatchManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MatchQueueCubit(
            tournamentRepository: context.read<ModelStore<TournamentEvent>>(),
            scheduleStore: context.read<ModelStore<Schedule>>(),
            scheduledMatchStore: context.read<ModelStore<ScheduledMatch>>(),
          ),
        ),
        BlocProvider(
          create: (context) => MatchStartStopCubit(
            cancelEndpoint: context.read<CancelMatchEndpoint>(),
            startEndpoint: context.read<StartMatchEndpoint>(),
          ),
        ),
        BlocProvider(
          create: (context) => MatchQueueSettingsCubit(
            tournamentRepository: context.read<ModelStore<TournamentEvent>>(),
          ),
        ),
      ],
      // Use a nested Navigator to get access to the MatchQueueCubit in the routes
      child: Navigator(
        key: const ValueKey('nested-match-management-navigator'),
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (context) => const _MatchManagementPageScaffold(),
        ),
      ),
    );
  }
}

class _MatchManagementPageScaffold extends StatelessWidget {
  const _MatchManagementPageScaffold();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.matchOperations)),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 80, bottom: 40),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(GameSheetPrintingPage.route());
          },
          heroTag: 'match_print_button',
          child: const Icon(Icons.print),
        ),
      ),
      body: const _MatchQueueLists(),
    );
  }
}

class _MatchQueueLists extends StatelessWidget {
  const _MatchQueueLists();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    TextStyle queueTitleStyle = const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 16,
    );

    return BlocBuilder<MatchQueueCubit, MatchQueueState>(
      builder: (context, state) {
        return LoadingScreen(
          loadingStatus: state.loadingStatus,
          builder: (context) {
            return DialogListener<MatchStartStopCubit, MatchStartStopState,
                bool>(
              builder: (context, state, reason) {
                return ConfirmDialog(
                  title: Text(l10n.cancelMatchConfirmation),
                  content: Text(l10n.cancelMatchInfo),
                  confirmButtonLabel: l10n.confirm,
                  cancelButtonLabel: l10n.cancel,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RoundQueueList(),
                  const SizedBox(width: 5),
                  MatchQueueList(
                    width: 250,
                    title: Column(
                      children: [
                        Text(
                          l10n.readyForCallout,
                          style: queueTitleStyle,
                        ),
                        const SizedBox(height: 10),
                        const _CallOutAllButton(),
                      ],
                    ),
                    list: _buildMatchList(
                      state.readyMatches,
                      (mContext) => TournamentMatchContextSubtree.fromContext(
                        key: ValueKey(
                          'ReadyForCallOutMatch-${mContext.match.id}',
                        ),
                        context: mContext,
                        child: ReadyForCallOutMatch(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  MatchQueueList(
                    width: 420,
                    title: Text(
                      l10n.runningMatches,
                      style: queueTitleStyle,
                    ),
                    list: _buildMatchList(
                      state.runningMatches,
                      (mContext) => TournamentMatchContextSubtree.fromContext(
                        key: ValueKey('RunningMatch-${mContext.match.id}'),
                        context: mContext,
                        child: RunningMatch(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildMatchList(
    List<MatchContext> matches,
    Widget Function(MatchContext mContext) matchItemBuilder,
  ) {
    return matches.map((match) => matchItemBuilder(match)).toList();
  }
}

class _CallOutAllButton extends StatelessWidget {
  const _CallOutAllButton();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BlocBuilder<MatchQueueCubit, MatchQueueState>(
      builder: (context, state) {
        return ElevatedButton(
          onPressed: state.readyMatches.isEmpty
              ? null
              : () {
                  showDialog(
                    context: context,
                    builder: (_) => CallOutScript(
                      callOuts: state.readyMatches,
                      matchStartingCubit: context.read<MatchStartStopCubit>(),
                    ),
                  );
                },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.campaign),
              const SizedBox(width: 7),
              Text(l10n.callOutAll),
            ],
          ),
        );
      },
    );
  }
}
