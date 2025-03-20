import 'package:ez_badminton_admin_app/court_management/cubit/cubit/court_cubit.dart';
import 'package:ez_badminton_admin_app/tournament_plans/cubit/tournament_plan_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:model_repository/model_repository.dart';

class CourtNavigationTabIcon extends StatelessWidget {
  const CourtNavigationTabIcon({
    required this.icon,
    super.key,
  });

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TournamentPlanCubit, TournamentPlanState>(
      builder: (context, state) {
        if (state.loadingStatus == LoadingStatus.loading) {
          return FaIcon(icon);
        }

        bool tournamentsRunning = state
            .getCollection<TournamentPlan>()
            .any((tPlan) => tPlan.started && !tPlan.ended);
        if (!tournamentsRunning) {
          return FaIcon(icon);
        }

        return BlocBuilder<CourtCubit, CourtState>(
          builder: (context, state) {
            if (state.loadingStatus == LoadingStatus.loading) {
              return FaIcon(icon);
            }

            int numOpenCourts =
                state.getCollection<Court>().length - state.occupied.length;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                FaIcon(icon),
                Positioned.fill(
                  top: null,
                  bottom: -40,
                  child: Center(
                    child: Container(
                      width: 35,
                      decoration: BoxDecoration(
                        color: numOpenCourts == 0
                            ? Colors.grey[350]
                            : Colors.green[300],
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Center(
                        child: Text(
                          '$numOpenCourts',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
