import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/court_management/court_editing/cubit/court_editing_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/court_list/cubit/court_list_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/court_list/view/court_list.dart';
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
          create: (context) => CourtEditingCubit(
            courtRepository: context.read<CollectionRepository<Court>>(),
            gymnasiumRepository:
                context.read<CollectionRepository<Gymnasium>>(),
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
        builder: (context, state) {
          return LoadingScreen(
            loadingStatus: state.loadingStatus,
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
              ],
            ),
          );
        },
      ),
    );
  }
}
