import 'package:equatable/equatable.dart';
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

class MatchContext<T extends Tournament> extends TournamentContext<T>
    with EquatableMixin {
  const MatchContext(super.tPlan, this.match, {super.tournament});
  final TournamentMatch match;

  @override
  List<Object?> get props => [match.id];
}

class ScheduledMatchContext<T extends Tournament> extends MatchContext<T> {
  ScheduledMatchContext(TournamentPlan tPlan, this.scheduledMatch)
      : super(tPlan, scheduledMatch.match);
  final ScheduledMatch scheduledMatch;
}

class TournamentContextSubtree extends StatelessWidget {
  const TournamentContextSubtree(this.tContext, {this.child, super.key});

  final TournamentContext tContext;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<TournamentContext>.value(
      value: tContext,
      child: child,
    );
  }
}

class MatchContextSubtree extends StatelessWidget {
  const MatchContextSubtree(this.mContext, {this.child, super.key});

  final MatchContext mContext;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<MatchContext>.value(
      value: mContext,
      child: child,
    );
  }
}
