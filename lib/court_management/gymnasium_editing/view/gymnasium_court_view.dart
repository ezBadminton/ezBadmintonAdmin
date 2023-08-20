import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/court_management/court_editing/cubit/court_adding_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/court_editing/view/court_slot.dart';
import 'package:ez_badminton_admin_app/court_management/court_list/cubit/court_list_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/cubit/gymnasium_court_view_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/cubit/gymnasium_selection_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/utils/gymnasium_court_view_controller.dart';
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

class _GymnasiumCourtView extends StatefulWidget {
  const _GymnasiumCourtView({
    required this.gymnasium,
  });

  final Gymnasium gymnasium;

  @override
  State<_GymnasiumCourtView> createState() => _GymnasiumCourtViewState();
}

class _GymnasiumCourtViewState extends State<_GymnasiumCourtView>
    with TickerProviderStateMixin {
  late final AnimationController _viewAnimationController;

  @override
  void initState() {
    super.initState();
    _viewAnimationController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _viewAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    GymnasiumCourtViewCubit viewCubit = context.read<GymnasiumCourtViewCubit>();

    GymnasiumCourtViewController viewController =
        viewCubit.getViewController(widget.gymnasium);

    viewController.animationController = _viewAnimationController;

    return BlocProvider(
      key: ObjectKey(widget.gymnasium),
      create: (context) => CourtAddingCubit(
        courtRepository: context.read<CollectionRepository<Court>>(),
        gymnasiumRepository: context.read<CollectionRepository<Gymnasium>>(),
        gymnasium: widget.gymnasium,
        l10n: l10n,
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        viewController.viewConstraints = constraints;

        return Stack(
          children: [
            InteractiveViewer(
              constrained: false,
              minScale: 0.01,
              maxScale: 1.5,
              boundaryMargin: gym_court_utils.getGymBoundaryMargin(
                constraints,
                widget.gymnasium,
              ),
              scaleFactor: 1500,
              transformationController: viewController,
              onInteractionStart: (_) => viewController.onInteractionStart(),
              child: _CourtGrid(
                gymnasium: widget.gymnasium,
                constraints: constraints,
              ),
            ),
            Positioned.fill(
              child: _ViewControlBar(gymnasium: widget.gymnasium),
            )
          ],
        );
      }),
    );
  }
}

class _ViewControlBar extends StatelessWidget {
  const _ViewControlBar({
    required this.gymnasium,
  });

  final Gymnasium gymnasium;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    GymnasiumCourtViewCubit viewCubit = context.read<GymnasiumCourtViewCubit>();

    GymnasiumCourtViewController viewController =
        viewCubit.getViewController(gymnasium);
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorLight.withOpacity(.9),
          borderRadius: const BorderRadius.vertical(
            top: Radius.zero,
            bottom: Radius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 9.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Tooltip(
                    message: l10n.zoom,
                    waitDuration: const Duration(milliseconds: 500),
                    child: TextButton(
                      onPressed: () => viewController.zoom(1 / 1.15),
                      child: const Icon(Icons.zoom_out),
                    ),
                  ),
                  Tooltip(
                    message: l10n.resetView,
                    waitDuration: const Duration(milliseconds: 500),
                    child: TextButton(
                      onPressed: viewController.fitToScreen,
                      child: const Icon(Icons.fit_screen_rounded),
                    ),
                  ),
                  Tooltip(
                    message: l10n.zoom,
                    waitDuration: const Duration(milliseconds: 500),
                    child: TextButton(
                      onPressed: () => viewController.zoom(1.15),
                      child: const Icon(Icons.zoom_in),
                    ),
                  ),
                ],
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 170,
                  maxWidth: 400,
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  widthFactor: 1,
                  heightFactor: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      gymnasium.name,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Icon(Icons.edit),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Icon(Icons.library_add),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
