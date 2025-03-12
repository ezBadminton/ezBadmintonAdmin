import 'package:ez_badminton_admin_app/match_management/cubit/match_queue_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/widgets/match_queue_list.dart';
import 'package:ez_badminton_admin_app/match_management/widgets/match_queue_settings.dart';
import 'package:ez_badminton_admin_app/match_management/widgets/round_queue/cubit/round_selection_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/widgets/round_queue/queued_round.dart';
import 'package:ez_badminton_admin_app/match_management/widgets/round_queue/round_match_queue_list.dart';
import 'package:ez_badminton_admin_app/widgets/pop_in_animation/pop_in_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model_repository/model_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RoundQueueList extends StatelessWidget {
  const RoundQueueList({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var state = context.read<MatchQueueCubit>().state;
    var queuedRounds = state.queuedRounds;
    TextStyle queueTitleStyle = const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 16,
    );

    bool isMatchPageEmpty = state.getCollection<ScheduledMatch>().isEmpty;
    return BlocProvider(
      create: (context) => RoundSelectionCubit(
        scheduledMatchStore: context.read(),
      ),
      child: BlocBuilder<RoundSelectionCubit, RoundSelectionState>(
        builder: (context, state) {
          Widget queuedRoundList = MatchQueueList(
            width: 420,
            title: Column(
              children: [
                Text(
                  l10n.matchQueue,
                  style: queueTitleStyle,
                ),
                const SizedBox(height: 10),
                const MatchQueueSettings(),
              ],
            ),
            list: isMatchPageEmpty
                ? [
                    const SizedBox(height: 150),
                    Center(
                      child: Text(
                        l10n.noMatchesHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(.25),
                          fontSize: 21,
                        ),
                      ),
                    ),
                  ]
                : queuedRounds
                    .map((round) => QueuedRound(scheduledRound: round))
                    .toList(),
          );

          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: PopInAnimation(
              poppedIn: state.showRound,
              background: queuedRoundList,
              foreground: RoundMatchQueueList(),
            ),
          );
        },
      ),
    );
  }
}
