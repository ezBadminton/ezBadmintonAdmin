import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/court_editing/cubit/court_adding_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/court_editing/view/court_slot.dart';
import 'package:ez_badminton_admin_app/court_management/court_list/cubit/court_list_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/court_numbering/cubit/court_numbering_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/court_numbering/cubit/court_numbering_dialog_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/court_numbering/view/court_numbering_dialog.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/cubit/gymnasium_court_view_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/cubit/gymnasium_deletion_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/cubit/gymnasium_selection_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/utils/gymnasium_court_view_controller.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/view/gymnasium_editing_page.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/dialog_listener.dart';
import 'package:ez_badminton_admin_app/widgets/dialogs/confirm_dialog.dart';
import 'package:ez_badminton_admin_app/widgets/transformation_zoom_buttons/transformation_zoom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/utils/gymnasium_court_view_utils.dart'
    as gym_court_utils;
import 'package:formz/formz.dart';

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
  _GymnasiumCourtView({
    required this.gymnasium,
  }) : super(key: ValueKey('${gymnasium.id}-GymnasiumCourtView'));

  final Gymnasium gymnasium;

  @override
  State<_GymnasiumCourtView> createState() => _GymnasiumCourtViewState();
}

class _GymnasiumCourtViewState extends State<_GymnasiumCourtView>
    with TickerProviderStateMixin {
  GymnasiumCourtViewController? _viewController;

  @override
  void didChangeDependencies() {
    GymnasiumCourtViewCubit viewCubit = context.read<GymnasiumCourtViewCubit>();

    if (_viewController == null) {
      _viewController = viewCubit.getViewController(widget.gymnasium);

      _viewController!.vsync = this;
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _viewController!.vsync = null;
    _viewController!.viewConstraints = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    var progressCubit = context.read<TournamentProgressCubit>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          key: ValueKey('${widget.gymnasium.id}-CourtAddingCubit'),
          create: (context) => CourtAddingCubit(
            courtRepository: context.read<CollectionRepository<Court>>(),
            gymnasiumRepository:
                context.read<CollectionRepository<Gymnasium>>(),
            gymnasium: widget.gymnasium,
            l10n: l10n,
          ),
        ),
        BlocProvider(
          key: ValueKey('${widget.gymnasium.id}-GymnasiumDeletionCubit'),
          create: (context) => GymnasiumDeletionCubit(
            gymnasium: widget.gymnasium,
            tournamentProgressGetter: () => progressCubit.state,
            gymnasiumRepository:
                context.read<CollectionRepository<Gymnasium>>(),
            courtRepository: context.read<CollectionRepository<Court>>(),
          ),
        ),
      ],
      child: LayoutBuilder(builder: (context, constraints) {
        _viewController!.viewConstraints = constraints;

        return Stack(
          children: [
            InteractiveViewer(
              constrained: false,
              minScale: 0.01,
              maxScale: gym_court_utils.maxZoomScale,
              boundaryMargin: gym_court_utils.getGymBoundaryMargin(
                constraints,
                widget.gymnasium,
              ),
              scaleFactor: 1500,
              transformationController: _viewController,
              onInteractionStart: (_) => _viewController!.onInteractionStart(),
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
              ZoomButtons(
                viewController: viewController,
                maxScale: gym_court_utils.maxZoomScale,
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
              _GymnasiumOptions(gymnasmium: gymnasium),
            ],
          ),
        ),
      ),
    );
  }
}

class _GymnasiumOptions extends StatelessWidget {
  const _GymnasiumOptions({
    required this.gymnasmium,
  });

  final Gymnasium gymnasmium;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var courtAddingcubit = context.read<CourtAddingCubit>();
    var deletionCubit = context.read<GymnasiumDeletionCubit>();
    var numberingCubit = context.read<CourtNumberingCubit>();
    return DialogListener<GymnasiumDeletionCubit, GymnasiumDeletionState,
        Error>(
      barrierDismissable: true,
      builder: (context, state, reason) {
        return AlertDialog(
          title: Text(l10n.cantDeleteHall),
          content: Text(l10n.cantDeleteHallInfo),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
      child:
          DialogListener<GymnasiumDeletionCubit, GymnasiumDeletionState, bool>(
        builder: (context, state, _) => ConfirmDialog(
          title: Text(l10n.deleteSubjectQuestion(l10n.gym(1))),
          content: Text(l10n.deleteGymWarning),
          confirmButtonLabel: l10n.confirm,
          cancelButtonLabel: l10n.cancel,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Tooltip(
              message: l10n.editSubject(l10n.gym(1)),
              waitDuration: const Duration(milliseconds: 500),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    GymnasiumEditingPage.route(gymnasmium),
                  );
                },
                child: const Icon(Icons.edit),
              ),
            ),
            Tooltip(
              message: l10n.addAllMissingCourts,
              waitDuration: const Duration(milliseconds: 500),
              child: TextButton(
                onPressed: courtAddingcubit.addAllMissingCourts,
                child: const Icon(Icons.library_add),
              ),
            ),
            DialogListener<CourtNumberingCubit, CourtNumberingState,
                CourtNumberingDialogState>(
              builder: (context, state, _) => const CourtNumberingDialog(),
              barrierDismissable: true,
              child: BlocBuilder<CourtNumberingCubit, CourtNumberingState>(
                builder: (context, numberingState) {
                  return BlocBuilder<GymnasiumDeletionCubit,
                      GymnasiumDeletionState>(
                    builder: (context, deletionState) {
                      return SizedBox(
                        height: 28,
                        child: PopupMenuButton<VoidCallback>(
                          onSelected: (callback) => callback(),
                          tooltip: '',
                          splashRadius: 19,
                          enabled: deletionState.formStatus !=
                                  FormzSubmissionStatus.inProgress &&
                              numberingState.formStatus !=
                                  FormzSubmissionStatus.inProgress,
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.more_vert,
                            color: Theme.of(context).primaryColor,
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: () =>
                                  numberingCubit.courtsNumbered(gymnasmium),
                              child: Text(l10n.numberCourts),
                            ),
                            PopupMenuItem(
                              value: deletionCubit.gymnasiumDeleted,
                              child: Text(
                                l10n.deleteSubject(l10n.gym(1)),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
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
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(.25),
          fontSize: 25,
        ),
      ),
    );
  }
}
