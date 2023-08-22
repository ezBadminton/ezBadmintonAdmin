import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/court_management/court_list/cubit/court_list_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/court_list/view/court_list.dart';
import 'package:ez_badminton_admin_app/court_management/court_numbering/cubit/court_numbering_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/cubit/gymnasium_court_view_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/cubit/gymnasium_selection_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/view/gymnasium_court_view.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text(l10n.courtManagement)),
      body: BlocBuilder<CourtListCubit, CourtListState>(
        buildWhen: (previous, current) =>
            previous.loadingStatus != current.loadingStatus,
        builder: (context, listState) {
          return BlocBuilder<GymnasiumSelectionCubit, GymnasiumSelectionState>(
            builder: (context, selectionState) {
              return LoadingScreen(
                loadingStatus: loadingStatusConjunction([
                  listState.loadingStatus,
                  selectionState.loadingStatus,
                ]),
                retryButtonLabel: l10n.retry,
                onRetry: () {
                  context.read<CourtListCubit>().loadCollections();
                  context.read<GymnasiumSelectionCubit>().loadCollections();
                },
                builder: (context) => const Row(
                  children: [
                    SizedBox(
                      width: 220,
                      child: Padding(
                        padding: EdgeInsets.only(top: 25.0),
                        child: Align(
                          alignment: AlignmentDirectional.topCenter,
                          child: CourtList(),
                        ),
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
              );
            },
          );
        },
      ),
    );
  }
}
