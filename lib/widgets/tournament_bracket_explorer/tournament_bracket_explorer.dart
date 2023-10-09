import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/draw_management/cubit/draw_deletion_cubit.dart';
import 'package:ez_badminton_admin_app/draw_management/cubit/drawing_cubit.dart';
import 'package:ez_badminton_admin_app/utils/animated_transformation_controller/animated_transformation_controller.dart';
import 'package:ez_badminton_admin_app/utils/confirmation_cubit/confirmation_cubit.dart';
import 'package:ez_badminton_admin_app/utils/simple_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/competition_label/competition_label.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/dialog_listener.dart';
import 'package:ez_badminton_admin_app/widgets/dialogs/confirm_dialog.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section_navigator.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/cubit/bracket_section_navigator_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/cubit/interactive_view_blocker_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/cubit/tournament_bracket_explorer_controller_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/edge_panning_area.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/tournament_bracket_explorer_controller.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/section_labels.dart';
import 'package:ez_badminton_admin_app/widgets/transformation_zoom_buttons/transformation_zoom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:local_hero/local_hero.dart';

class TournamentBracketExplorer extends StatefulWidget {
  const TournamentBracketExplorer({
    super.key,
    required this.competition,
    required this.tournamentBracket,
  });

  final Competition competition;
  final Widget tournamentBracket;

  @override
  State<TournamentBracketExplorer> createState() =>
      _TournamentBracketExplorerState();
}

class _TournamentBracketExplorerState extends State<TournamentBracketExplorer>
    with TickerProviderStateMixin {
  TournamentBracketExplorerController? _viewController;
  bool _viewInitialized = false;

  @override
  void didChangeDependencies() {
    var controllerCubit =
        context.read<TournamentBracketExplorerControllerCubit>();

    if (_viewController == null) {
      _viewController = controllerCubit.getViewController(widget.competition);
      _viewController!.vsync = this;
    }

    _viewInitialized = _viewController!.viewConstraints != null;

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _viewController?.vsync = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => BracketSectionNavigatorCubit(
            viewController: _viewController!,
          ),
        ),
        BlocProvider(
          create: (context) => SimpleCubit<EdgeInsets>(EdgeInsets.zero),
        ),
        BlocProvider(
          create: (context) => InteractiveViewBlockerCubit(),
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          var sectionNavigatorcubit =
              context.read<BracketSectionNavigatorCubit>();
          var boundaryCubit = context.read<SimpleCubit<EdgeInsets>>();
          _viewController!.viewConstraints = constraints;

          // Wait for the bracket view to be painted so the
          // render box sizes are available
          Future.delayed(
            Duration.zero,
            () {
              sectionNavigatorcubit.onViewChanged();
              boundaryCubit.changeState(
                _viewController!.boundaryMargin,
              );
              if (!_viewInitialized) {
                _viewController!.fitToScreen();
                _viewInitialized = true;
              }
            },
          );

          return BlocBuilder<InteractiveViewBlockerCubit,
              InteractiveViewBlockerState>(
            builder: (context, blockerState) {
              return Stack(
                children: [
                  BlocBuilder<SimpleCubit<EdgeInsets>, EdgeInsets>(
                    builder: (context, boundaryMargin) {
                      return InteractiveViewer(
                        constrained: false,
                        minScale: .01,
                        maxScale: 1.33,
                        scaleEnabled: !blockerState.isZoomBlocked,
                        boundaryMargin: boundaryMargin,
                        scaleFactor: 1500,
                        transformationController: _viewController,
                        child: LocalHeroScope(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOutQuad,
                          onlyAnimateRemount: true,
                          child: KeyedSubtree(
                            key: _viewController!.bracketViewKey,
                            child: widget.tournamentBracket,
                          ),
                        ),
                      );
                    },
                  ),
                  Column(
                    children: [
                      if (widget.tournamentBracket is SectionLabels)
                        BracketSectionNavigator(
                          constraints: constraints,
                          sectionLabels:
                              (widget.tournamentBracket as SectionLabels)
                                  .getSectionLabels(l10n),
                          viewController: _viewController!,
                        ),
                      _ViewControlBar(competition: widget.competition),
                    ],
                  ),
                  Positioned.fill(
                    child: EdgePanningArea(
                      transformationController: _viewController!,
                      enabled: !blockerState.isEdgePanBlocked,
                      panEdges: const EdgeInsets.all(50),
                      panScaleCurve: Curves.easeInCirc,
                      panSpeed: 6.0,
                      child: const SizedBox.expand(),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ViewControlBar extends StatelessWidget {
  const _ViewControlBar({
    required this.competition,
  });

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    var controllerCubit =
        context.read<TournamentBracketExplorerControllerCubit>();

    AnimatedTransformationController viewController =
        controllerCubit.getViewController(competition);

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ZoomButtons(
                viewController: viewController,
                maxScale: 1.33,
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 230,
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  widthFactor: 1,
                  heightFactor: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: CompetitionLabel(
                      competition: competition,
                      abbreviated: true,
                      textStyle: const TextStyle(fontSize: 17),
                      playingLevelMaxWidth: 100,
                    ),
                  ),
                ),
              ),
              const _DrawOptions(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawOptions extends StatelessWidget {
  const _DrawOptions();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    var drawingCubit = context.read<DrawingCubit>();
    var drawDeletionCubit = context.read<DrawDeletionCubit>();

    return BlocProvider(
      create: (context) => ConfirmationCubit(),
      child: DialogListener<ConfirmationCubit, ConfirmationState, bool>(
        builder: (context, state, reason) {
          String title = switch (reason as _ConfirmReason) {
            _ConfirmReason.undoManualDraw => l10n.undoManualDraw,
            _ConfirmReason.redraw => l10n.redraw,
            _ConfirmReason.deleteDraw => l10n.deleteSubject(l10n.draw(1)),
          };

          String body = switch (reason) {
            _ConfirmReason.undoManualDraw => l10n.undoManualDrawWarning,
            _ConfirmReason.redraw => l10n.redrawWarning,
            _ConfirmReason.deleteDraw => l10n.deleteDrawWarning,
          };

          return ConfirmDialog(
            title: Text(title),
            content: Text(body),
            confirmButtonLabel: l10n.confirm,
            cancelButtonLabel: l10n.cancel,
          );
        },
        child: Builder(builder: (context) {
          var confirmationCubit = context.read<ConfirmationCubit>();

          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Tooltip(
                message: l10n.undoManualDraw,
                waitDuration: const Duration(milliseconds: 500),
                child: TextButton(
                  onPressed: () => confirmationCubit.executeWithConfirmation(
                    drawingCubit.makeDraw,
                    reason: _ConfirmReason.undoManualDraw,
                  ),
                  child: const Icon(Icons.restore),
                ),
              ),
              Tooltip(
                message: l10n.redraw,
                waitDuration: const Duration(milliseconds: 500),
                child: TextButton(
                  onPressed: () => confirmationCubit.executeWithConfirmation(
                    drawingCubit.redraw,
                    reason: _ConfirmReason.redraw,
                  ),
                  child: const Icon(Icons.casino_outlined),
                ),
              ),
              Tooltip(
                message: l10n.deleteSubject(l10n.draw(1)),
                waitDuration: const Duration(milliseconds: 500),
                child: TextButton(
                  onPressed: () => confirmationCubit.executeWithConfirmation(
                    drawDeletionCubit.deleteDraw,
                    reason: _ConfirmReason.deleteDraw,
                  ),
                  child: const Icon(Icons.delete),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

enum _ConfirmReason {
  undoManualDraw,
  redraw,
  deleteDraw,
}
