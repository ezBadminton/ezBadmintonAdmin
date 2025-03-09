import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model_repository/model_repository.dart';

class TournamentContext<T extends Tournament> {
  const TournamentContext(this.tPlan, {T? tournament})
      : _tournament = tournament;
  final TournamentPlan tPlan;
  final T? _tournament;
  Competition get competition => tPlan.competition;
  T get tournament => _tournament ?? tPlan.tournament as T;

  TournamentContext<C> copyWith<C extends Tournament>(C tournament) =>
      TournamentContext(tPlan, tournament: tournament);
}

class MatchContext<T extends Tournament> extends TournamentContext<T> {
  const MatchContext(super.tPlan, this.match);
  final TournamentMatch match;
}

class ScheduledMatchContext<T extends Tournament> extends MatchContext<T> {
  ScheduledMatchContext(TournamentPlan tPlan, this.scheduledMatch)
      : super(tPlan, scheduledMatch.match);
  final ScheduledMatch scheduledMatch;
}

class TournamentContextSubtree<C extends TournamentContext>
    extends StatelessWidget {
  const TournamentContextSubtree(this.tContext, {this.child, super.key});

  final C tContext;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(value: tContext, child: child);
  }
}
