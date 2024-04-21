import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:ez_badminton_admin_app/draw_management/plan_printing/cubit/plan_printing_cubit.dart';
import 'package:ez_badminton_admin_app/printing/open_pdf_button.dart';
import 'package:ez_badminton_admin_app/widgets/competition_selection_list/competition_multi_selection_list.dart';
import 'package:ez_badminton_admin_app/widgets/competition_selection_list/cubit/competition_multi_selection_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/pdf_document_preview/pdf_document_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PlanPrintingPage extends StatelessWidget {
  const PlanPrintingPage({super.key});

  static Route route() {
    return MaterialPageRoute(
      builder: (_) => const PlanPrintingPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var progressCubit = context.read<TournamentProgressCubit>();
    var l10n = AppLocalizations.of(context)!;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PlanPrintingCubit(
            l10n: l10n,
          ),
        ),
        BlocProvider(
          create: (context) => CompetitionMultiSelectionCubit(
            competitionRepository:
                context.read<CollectionRepository<Competition>>(),
          ),
        ),
      ],
      child: BlocListener<CompetitionMultiSelectionCubit,
          CompetitionMultiSelectionState>(
        listener: (context, state) {
          var cubit = context.read<PlanPrintingCubit>();

          List<BadmintonTournamentMode> tournaments = state.selectedCompetitions
              .map((c) => progressCubit.state.runningTournaments[c])
              .whereType<BadmintonTournamentMode>()
              .toList();

          cubit.tournamentsChanged(tournaments);
        },
        child: const _PlanPrintingPageScaffold(),
      ),
    );
  }
}

class _PlanPrintingPageScaffold extends StatelessWidget {
  const _PlanPrintingPageScaffold();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.planPrinting)),
      body: BlocBuilder<PlanPrintingCubit, PlanPrintingState>(
        builder: (context, state) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 370,
                child: CompetitionMutliSelectionList(),
              ),
              const VerticalDivider(
                thickness: 1,
                width: 1,
                color: Colors.black26,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      const OpenPdfButton<PlanPrintingCubit,
                          PlanPrintingState>(),
                      const SizedBox(height: 8),
                      const OpenPdfSaveLocationButton<PlanPrintingCubit,
                          PlanPrintingState>(),
                      const SizedBox(height: 30),
                      Text(
                        l10n.preview,
                        style: const TextStyle(fontSize: 22),
                      ),
                      const Divider(height: 25, indent: 20, endIndent: 20),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 1100,
                          maxHeight: 750,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15.0,
                          ),
                          child: PdfDocumentPreview(
                            document: state.pdfDocument.value,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
