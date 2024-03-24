import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/court_management/court_list/cubit/court_list_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/court_list/view/court_list.dart';
import 'package:ez_badminton_admin_app/court_management/court_numbering/cubit/court_numbering_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/cubit/gymnasium_court_view_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/cubit/gymnasium_selection_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/view/gymnasium_court_view.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/cubit/match_court_assignment_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:ez_badminton_admin_app/widgets/tab_navigation_back_button/tab_navigation_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:formz/formz.dart';

class CourtListPage extends StatelessWidget {
  const CourtListPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CourtListCubit(
            courtRepository: context.read<CollectionRepository<Court>>(),
            gymnasiumRepository:
                context.read<CollectionRepository<Gymnasium>>(),
          ),
        ),
        BlocProvider(
          create: (context) => GymnasiumSelectionCubit(
            gymnasiumRepository:
                context.read<CollectionRepository<Gymnasium>>(),
            courtRepository: context.read<CollectionRepository<Court>>(),
          ),
        ),
        BlocProvider(
          create: (context) => GymnasiumCourtViewCubit(
            gymnasiumRepository:
                context.read<CollectionRepository<Gymnasium>>(),
          ),
        ),
        BlocProvider(
          create: (context) => CourtNumberingCubit(
            gymnasiumRepository:
                context.read<CollectionRepository<Gymnasium>>(),
            courtRepository: context.read<CollectionRepository<Court>>(),
            l10n: l10n,
          ),
        ),
      ],
      child: const _CourtListPageScaffold(),
    );
  }
}

class _CourtListPageScaffold extends StatelessWidget {
  const _CourtListPageScaffold();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return TabNavigationBackButtonBuilder(
      builder: (context, backButton) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.courtManagement),
          leading: backButton,
        ),
        body: BlocBuilder<CourtListCubit, CourtListState>(
          buildWhen: (previous, current) =>
              previous.loadingStatus != current.loadingStatus,
          builder: (context, listState) {
            return BlocBuilder<GymnasiumSelectionCubit,
                GymnasiumSelectionState>(
              builder: (context, selectionState) {
                return BlocListener<MatchCourtAssignmentCubit,
                    MatchCourtAssignmentState>(
                  listenWhen: (previous, current) =>
                      previous.formStatus != FormzSubmissionStatus.success &&
                      current.formStatus == FormzSubmissionStatus.success,
                  listener: (context, state) {
                    var cubit = context.read<TabNavigationCubit>();

                    if (cubit.state.selectedIndex == 2) {
                      // Go back to match page when a court was assigned
                      cubit.tabChanged(4);
                    }
                  },
                  child: LoadingScreen(
                    loadingStatus: loadingStatusConjunction([
                      listState.loadingStatus,
                      selectionState.loadingStatus,
                    ]),
                    builder: (context) => const Row(
                      children: [
                        SizedBox(
                          width: 220,
                          child: Align(
                            alignment: AlignmentDirectional.topCenter,
                            child: CourtList(),
                          ),
                        ),
                        VerticalDivider(
                          thickness: 1,
                          width: 1,
                          color: Colors.black26,
                        ),
                        Expanded(child: GymnasiumCourtView()),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
