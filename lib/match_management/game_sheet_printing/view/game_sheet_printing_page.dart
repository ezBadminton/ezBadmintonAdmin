import 'dart:math';

import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/game_sheet_printing/cubit/game_sheet_printing_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/game_sheet_printing/cubit/sheet_printing_option_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/game_sheet_printing/widgets/game_sheet_pdf_preview.dart';
import 'package:ez_badminton_admin_app/match_management/game_sheet_printing/widgets/game_sheet_preview_title.dart';
import 'package:ez_badminton_admin_app/match_management/game_sheet_printing/widgets/sheet_printing_options.dart';
import 'package:ez_badminton_admin_app/match_management/game_sheet_printing/widgets/sheet_printing_selection_widget.dart';
import 'package:ez_badminton_admin_app/widgets/help_tooltip_icon/help_tooltip_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GameSheetPrintingPage extends StatelessWidget {
  const GameSheetPrintingPage({super.key});

  static Route route() {
    return MaterialPageRoute(
      builder: (_) => const GameSheetPrintingPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var progressCubit = context.read<TournamentProgressCubit>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          lazy: false,
          create: (context) => GameSheetPrintingCubit(
            l10n: l10n,
            tournamentProgressState: progressCubit.state,
            matchDataRepository:
                context.read<CollectionRepository<MatchData>>(),
            tournamentRepository:
                context.read<CollectionRepository<Tournament>>(),
          ),
        ),
        BlocProvider(
          create: (context) => SheetPrintingOptionCubit(
            tournamentRepository:
                context.read<CollectionRepository<Tournament>>(),
          ),
        ),
      ],
      child: const _GameSheetPrintingPageScaffold(),
    );
  }
}

class _GameSheetPrintingPageScaffold extends StatelessWidget {
  const _GameSheetPrintingPageScaffold();

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<GameSheetPrintingCubit>();
    var l10n = AppLocalizations.of(context)!;

    return BlocListener<TournamentProgressCubit, TournamentProgressState>(
      listener: (context, state) {
        cubit.tournamentProgressChanged(state);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.gameSheetPrinting)),
        body: Align(
          alignment: AlignmentDirectional.topCenter,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                SizedBox(
                  width: 700,
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.gameSheetPrintingTitle,
                            style: const TextStyle(fontSize: 22),
                          ),
                          const SizedBox(width: 8),
                          HelpTooltipIcon(helpText: l10n.gameSheetPrintingHelp)
                        ],
                      ),
                      const Divider(height: 25, indent: 20, endIndent: 20),
                      const SheetPrintingSelectionWidget(),
                      const SizedBox(height: 15),
                      const SheetPrintingOptions(),
                      const SizedBox(height: 40),
                      const GameSheetPreviewTitle(),
                      const Divider(height: 25, indent: 20, endIndent: 20),
                    ],
                  ),
                ),
                LayoutBuilder(builder: (context, constraints) {
                  double previewWidth = 1200;
                  double padding =
                      max(15, 0.5 * (constraints.maxWidth - previewWidth));
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: SizedBox(
                      width: previewWidth,
                      height: 900,
                      child: const GameSheetPdfPreview(),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
