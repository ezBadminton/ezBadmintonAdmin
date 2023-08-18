import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/court_management/court_editing/cubit/court_adding_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/court_editing/view/court_slot.dart';
import 'package:ez_badminton_admin_app/court_management/court_list/cubit/court_list_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/cubit/gymnasium_selection_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/utils/gymnasium_court_view_utils.dart'
    as gym_court_utils;

class GymnasiumCourtView extends StatelessWidget {
  const GymnasiumCourtView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourtListCubit, CourtListState>(
      builder: (context, listState) {
        bool gymsExist = listState.getCollection<Gymnasium>().isNotEmpty;

        return BlocBuilder<GymnasiumSelectionCubit, GymnasiumSelectionState>(
          builder: (context, selectionState) {
            Gymnasium? selectedGym = selectionState.gymnasium.value;

            if (selectedGym == null) {
              return _SelectionHint(gymsExist: gymsExist);
            } else {
              return _GymnasiumCourtView(gymnasium: selectedGym);
            }
          },
        );
      },
    );
  }
}

class _GymnasiumCourtView extends StatelessWidget {
  const _GymnasiumCourtView({
    required this.gymnasium,
  });

  final Gymnasium gymnasium;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      key: ObjectKey(gymnasium),
      create: (context) => CourtAddingCubit(
        courtRepository: context.read<CollectionRepository<Court>>(),
        gymnasiumRepository: context.read<CollectionRepository<Gymnasium>>(),
        gymnasium: gymnasium,
        l10n: l10n,
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        return InteractiveViewer(
          constrained: false,
          minScale: .1,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          scaleFactor: 4000,
          child: _CourtGrid(
            gymnasium: gymnasium,
            constraints: constraints,
          ),
        );
      }),
    );
  }
}

class _CourtGrid extends StatelessWidget {
  const _CourtGrid({
    required this.gymnasium,
    required this.constraints,
  });

  final Gymnasium gymnasium;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    EdgeInsets courtSlotPadding = gym_court_utils.getGymCourtPadding(
      constraints,
      gymnasium,
    );
    return Column(children: [
      for (int row = 0; row < gymnasium.rows; row += 1)
        Row(children: [
          for (int column = 0; column < gymnasium.columns; column += 1)
            Padding(
              padding: courtSlotPadding,
              child: SizedBox(
                width: gym_court_utils.courtWidth,
                height: gym_court_utils.courtHeight,
                child: CourtSlot(row: row, column: column),
              ),
            ),
        ]),
    ]);
  }
}

class _SelectionHint extends StatelessWidget {
  const _SelectionHint({
    required this.gymsExist,
  });

  final bool gymsExist;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return Center(
      child: Text(
        gymsExist ? l10n.noGymnasiumSelected : l10n.addFirstGymnasium,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(.25),
          fontSize: 25,
        ),
      ),
    );
  }
}
