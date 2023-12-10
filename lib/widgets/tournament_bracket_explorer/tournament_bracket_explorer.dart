import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/utils/animated_transformation_controller/animated_transformation_controller.dart';
import 'package:ez_badminton_admin_app/utils/simple_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/competition_label/competition_label.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section_navigator.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/cubit/bracket_section_navigator_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/cubit/interactive_view_blocker_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/cubit/tournament_bracket_explorer_controller_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/edge_panning_area.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/tournament_bracket_explorer_controller.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/sectioned_bracket.dart';
import 'package:ez_badminton_admin_app/widgets/transformation_zoom_buttons/transformation_zoom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_hero/local_hero.dart';

class TournamentBracketExplorer extends StatefulWidget {
  const TournamentBracketExplorer({
    super.key,
    required this.competition,
    required this.tournamentBracket,
    required this.controlBarOptionsBuilder,
  });

  final Competition competition;
  final Widget tournamentBracket;

  final Widget Function(bool compact) controlBarOptionsBuilder;

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
                      if (widget.tournamentBracket is SectionedBracket)
                        BracketSectionNavigator(
                          constraints: constraints,
                          sections:
                              (widget.tournamentBracket as SectionedBracket)
                                  .sections,
                          viewController: _viewController!,
                        ),
                      _ViewControlBar(
                        competition: widget.competition,
                        controlBarOptionsBuilder:
                            widget.controlBarOptionsBuilder,
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
}

class _ViewControlBar extends StatelessWidget {
  const _ViewControlBar({
    required this.competition,
    required this.controlBarOptionsBuilder,
  });

  final Competition competition;

  final Widget Function(bool compact) controlBarOptionsBuilder;

  @override
  Widget build(BuildContext context) {
    var controllerCubit =
        context.read<TournamentBracketExplorerControllerCubit>();

    AnimatedTransformationController viewController =
        controllerCubit.getViewController(competition);

    return LayoutBuilder(builder: (context, constraints) {
      bool compact = constraints.maxWidth < 560;
      bool tiny = constraints.maxWidth < 410;

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
                ZoomButtons(
                  viewController: viewController,
                  maxScale: 1.33,
                ),
                if (!tiny)
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 230,
                      minWidth: compact ? 170 : 185,
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
                          textStyle: TextStyle(fontSize: compact ? 14 : 16),
                          playingLevelMaxWidth: 100,
                        ),
                      ),
                    ),
                  ),
                controlBarOptionsBuilder(compact),
              ],
            ),
          ),
        ),
      );
    });
  }
}
