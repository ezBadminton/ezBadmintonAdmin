import 'package:equatable/equatable.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_context/cubit/match_context_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_context/cubit/tournament_context_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_context/cubit/tournament_plan_context_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model_repository/model_repository.dart';

class MatchContext extends Equatable {
  const MatchContext({
    TournamentMatch? match,
    ScheduledMatch? scheduledMatch,
    required this.tournamentPlan,
  })  : _match = match,
        _scheduledMatch = scheduledMatch;
  final TournamentPlan tournamentPlan;
  final TournamentMatch? _match;
  final ScheduledMatch? _scheduledMatch;

  TournamentMatch get match => _match ?? _scheduledMatch!.match;
  ScheduledMatch get scheduledMatch => _scheduledMatch!;

  @override
  List<Object?> get props => [match.id];
}

class TournamentPlanContextSubtree extends StatelessWidget {
  const TournamentPlanContextSubtree({
    required this.competition,
    this.child,
    super.key,
  });

  final Competition competition;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TournamentPlanContextCubit(
        competition: competition,
        tournamentPlanStore: context.read(),
      ),
      child: child,
    );
  }
}

class TournamentContextSubtree extends StatelessWidget {
  const TournamentContextSubtree({
    required this.tournamentGetter,
    this.child,
    super.key,
  });

  final Tournament Function(TournamentPlan plan) tournamentGetter;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TournamentContextCubit(tournamentGetter),
      child: child,
    );
  }
}

class MatchContextSubtree extends StatelessWidget {
  const MatchContextSubtree({
    required this.match,
    this.child,
    super.key,
  });

  final TournamentMatch match;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MatchContextCubit(
        match: match,
        tournamentMatchStore: context.read(),
        scheduledMatchStore: context.read(),
      ),
      child: child,
    );
  }
}

class ScheduledMatchContextSubtree extends StatelessWidget {
  const ScheduledMatchContextSubtree({
    required this.match,
    this.child,
    super.key,
  });

  final ScheduledMatch match;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MatchContextCubit(
        scheduledMatch: match,
        tournamentMatchStore: context.read(),
        scheduledMatchStore: context.read(),
      ),
      child: child,
    );
  }
}

class TournamentMatchContextSubtree extends StatelessWidget {
  const TournamentMatchContextSubtree({
    required this.competition,
    required this.match,
    this.child,
    super.key,
  });

  TournamentMatchContextSubtree.fromContext({
    required MatchContext context,
    this.child,
    super.key,
  })  : competition = context.tournamentPlan.competition,
        match = context._scheduledMatch ?? context._match;

  final Competition competition;
  final dynamic match;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TournamentPlanContextCubit(
        competition: competition,
        tournamentPlanStore: context.read(),
      ),
      child: BlocProvider(
        create: (context) => MatchContextCubit(
          match: (match is TournamentMatch) ? match : null,
          scheduledMatch: (match is ScheduledMatch) ? match : null,
          tournamentMatchStore: context.read(),
          scheduledMatchStore: context.read(),
        ),
        child: child,
      ),
    );
  }
}

extension MatchContextReaders on BuildContext {
  TournamentPlan readTournamentPlan() {
    var tPlanContext = read<TournamentPlanContextCubit>();
    return tPlanContext.state.tournamentPlan;
  }

  Tournament readTournament() {
    var tPlanContext = read<TournamentPlanContextCubit>();
    var tPlan = tPlanContext.state.tournamentPlan;
    try {
      var tournamentContext = read<TournamentContextCubit>();
      return tournamentContext.state.tournamentGetter(tPlan);
    } catch (_) {
      return tPlan.tournament;
    }
  }

  TournamentMatch readMatch() {
    var mContext = read<MatchContextCubit>();
    return mContext.state.match;
  }

  ScheduledMatch readScheduledMatch() {
    var mContext = read<MatchContextCubit>();
    return mContext.state.scheduledMatch;
  }

  MatchContext readMatchContext() {
    var tPlanContext = read<TournamentPlanContextCubit>();
    var tPlan = tPlanContext.state.tournamentPlan;
    try {
      var scheduledMatch = readScheduledMatch();
      return MatchContext(
        tournamentPlan: tPlan,
        scheduledMatch: scheduledMatch,
      );
    } catch (_) {
      var match = readMatch();
      return MatchContext(tournamentPlan: tPlan, match: match);
    }
  }
}
