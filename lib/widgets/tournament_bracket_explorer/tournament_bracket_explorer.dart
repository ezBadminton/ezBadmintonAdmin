import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/utils/simple_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section_navigator.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/cubit/bracket_section_navigator_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/cubit/tournament_bracket_explorer_controller_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/tournament_bracket_explorer_controller.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/section_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

          return Stack(
            children: [
              BlocBuilder<SimpleCubit<EdgeInsets>, EdgeInsets>(
                builder: (context, boundaryMargin) {
                  return InteractiveViewer(
                    constrained: false,
                    minScale: .01,
                    maxScale: 1.33,
                    boundaryMargin: boundaryMargin,
                    scaleFactor: 1500,
                    transformationController: _viewController,
                    child: KeyedSubtree(
                      key: _viewController!.bracketViewKey,
                      child: widget.tournamentBracket,
                    ),
                  );
                },
              ),
              if (widget.tournamentBracket is SectionLabels)
                BracketSectionNavigator(
                  constraints: constraints,
                  sectionLabels: (widget.tournamentBracket as SectionLabels)
                      .getSectionLabels(l10n),
                  viewController: _viewController!,
                )
            ],
          );
        },
      ),
    );
  }
}
