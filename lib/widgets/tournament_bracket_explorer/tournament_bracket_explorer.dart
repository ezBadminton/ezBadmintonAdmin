import 'dart:async';
import 'dart:math';

import 'package:ez_badminton_admin_app/utils/simple_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/competition_label/competition_label.dart';
import 'package:ez_badminton_admin_app/widgets/grid_painter/grid_painter.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section_navigator.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section_subtree.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/cubit/bracket_section_navigator_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/cubit/interactive_view_blocker_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/cubit/bracket_explorer_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/edge_panning_area.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/tournament_bracket_explorer_controller.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/sectioned_bracket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_hero/local_hero.dart';
import 'package:model_repository/model_repository.dart';

class TournamentBracketExplorer extends StatefulWidget {
  const TournamentBracketExplorer({
    required Key key,
    required this.competition,
    required this.tournamentBracket,
  }) : super(key: key);

  final Competition competition;
  final SectionedBracket tournamentBracket;

  @override
  State<TournamentBracketExplorer> createState() =>
      _TournamentBracketExplorerState();
}

class _TournamentBracketExplorerState extends State<TournamentBracketExplorer>
    with TickerProviderStateMixin {
  TournamentBracketExplorerController? _viewController;
  bool _viewInitialized = false;
  StreamSubscription? _commandSubscription;

  @override
  void didChangeDependencies() {
    var controllerCubit = context.read<BracketExplorerCubit>();

    _viewInitialized = _viewController != null;
    if (!_viewInitialized) {
      _viewController = controllerCubit.getViewController(widget.competition);
      _viewController!.vsync = this;
    }

    if (_commandSubscription == null) {
      var commandStream = context
          .read<PocketbaseRealtimeRepository<InfoscreenCommand>>()
          .messageStream;

      _commandSubscription = commandStream.listen(
        (command) {
          if (command.reset) {
            fitBracketIntoView();
            return;
          }
          Offset target = _viewController!.currentSceneFocus + command.pan;
          double currentScale = _viewController!.currentTransform.row0[0];
          if (command.zoomIn) {
            double newScale = currentScale * 1.4;
            currentScale = min(newScale, 2.5);
          } else if (command.zoomOut) {
            currentScale *= 0.7;
          }
          _viewController!.focusPoint(target, currentScale);
        },
      );
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _viewController?.vsync = null;
    _commandSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          WidgetsBinding.instance.addPostFrameCallback(
            (_) {
              sectionNavigatorcubit.onViewChanged();
              boundaryCubit.changeState(
                _viewController!.boundaryMargin,
              );
              if (!_viewInitialized) {
                _viewInitialized = true;
                fitBracketIntoView();
              }
            },
          );

          Widget bracketWithBackground = Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -10000,
                left: -10000,
                child: SizedBox(
                  height: 30000,
                  width: 30000,
                  child: DecorativeGrid(),
                ),
              ),
              widget.tournamentBracket as Widget,
            ],
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
                        minScale: .001,
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
                            child: bracketWithBackground,
                          ),
                        ),
                      );
                    },
                  ),
                  Column(
                    children: [
                      if (widget.tournamentBracket.navigatable)
                        BracketSectionNavigator(
                          constraints: constraints,
                          sections: widget.tournamentBracket.sections,
                          viewController: _viewController!,
                        ),
                      _ViewControlBar(
                        viewKey: widget.key!,
                        competition: widget.competition,
                      ),
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

  void fitBracketIntoView() {
    List<BracketSection> sections = widget.tournamentBracket.sections;
    List<GlobalKey> keys = sections
        .expand(
          (s) => s.tournamentDataObjects.map(
            (o) => getBracketSectionKey(context, o),
          ),
        )
        .toList();
    _viewController!.focusGlobalKeys(keys);
  }
}

class _ViewControlBar extends StatelessWidget {
  const _ViewControlBar({
    required this.viewKey,
    required this.competition,
  });

  final Key viewKey;
  final Competition competition;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Center(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight.withOpacity(.9),
            borderRadius: const BorderRadius.vertical(
              top: Radius.zero,
              bottom: Radius.circular(15),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 9.0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 290,
                    minWidth: 185,
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    widthFactor: 1,
                    heightFactor: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: CompetitionLabel(
                        competition: competition,
                        abbreviated: false,
                        textStyle: TextStyle(fontSize: 16),
                        playingLevelMaxWidth: 100,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
