import 'package:ez_badminton_admin_app/result_management/certificate_printing/cubit/certificate_printing_cubit.dart';
import 'package:ez_badminton_admin_app/tournament_plans/cubit/tournament_plan_cubit.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/printing/open_pdf_button.dart';
import 'package:ez_badminton_admin_app/widgets/competition_selection_list/competition_multi_selection_list.dart';
import 'package:ez_badminton_admin_app/widgets/competition_selection_list/cubit/competition_multi_selection_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/pdf_document_preview/pdf_document_preview.dart';
import 'package:ez_badminton_admin_app/widgets/help_tooltip_icon/help_tooltip_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ez_badminton_admin_app/l10n/l10n.dart';

class CertificatePrintingPage extends StatelessWidget {
  const CertificatePrintingPage({
    super.key,
    this.initiallySelectedCompetition,
  });

  static Route route(Competition? initiallySelectedCompetition) {
    return MaterialPageRoute(
      builder: (_) => CertificatePrintingPage(
        initiallySelectedCompetition: initiallySelectedCompetition,
      ),
    );
  }

  final Competition? initiallySelectedCompetition;

  @override
  Widget build(BuildContext context) {
    var planCubit = context.read<TournamentPlanCubit>();
    var l10n = AppLocalizations.of(context)!;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CertificatePrintingCubit(
            l10n: l10n,
            templateStore: context.read(),
          ),
        ),
        BlocProvider(
          create: (context) {
            CompetitionMultiSelectionCubit cubit =
                CompetitionMultiSelectionCubit(
              competitionRepository: context.read<ModelStore<Competition>>(),
              competitionPreFilter: (Competition competition) =>
                  competition.draw.isNotEmpty,
            );

            if (initiallySelectedCompetition != null) {
              Future.delayed(Duration.zero).then((_) {
                cubit.competitionToggled(initiallySelectedCompetition!);
              });
            }
            return cubit;
          },
        ),
      ],
      child: BlocListener<CompetitionMultiSelectionCubit,
          CompetitionMultiSelectionState>(
        listener: (context, state) {
          var cubit = context.read<CertificatePrintingCubit>();

          List<TournamentPlan> tournaments = state.selectedCompetitions
              .map(
                (c) =>
                    planCubit.state.drawnTournaments[c] ??
                    planCubit.state.runningTournaments[c],
              )
              .whereType<TournamentPlan>()
              .toList();

          cubit.competitionsChanged(tournaments);
        },
        child: const _CertificatePrintingPageScaffold(),
      ),
    );
  }
}

class _CertificatePrintingPageScaffold extends StatelessWidget {
  const _CertificatePrintingPageScaffold();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.certificatePrinting)),
      body: BlocBuilder<CertificatePrintingCubit, CertificatePrintingState>(
        buildWhen: (previous, current) =>
            previous.pdfDocument != current.pdfDocument,
        builder: (context, state) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 370,
                child: CompetitionMutliSelectionList(
                  emptyListPlaceholder: Text(
                    l10n.noDrawnCompetitions,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(.25),
                      fontSize: 21,
                    ),
                  ),
                ),
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.certificatePrintingTopN(numCertifiedPlaces),
                            style: const TextStyle(fontSize: 22),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(width: 8),
                          HelpTooltipIcon(helpText: l10n.certificatePrintingHelp),
                        ],
                      ),
                      const Divider(height: 25, indent: 20, endIndent: 20),
                      const OpenPdfButton<CertificatePrintingCubit,
                          CertificatePrintingState>(),
                      const SizedBox(height: 8),
                      const OpenPdfSaveLocationButton<CertificatePrintingCubit,
                          CertificatePrintingState>(),
                      const SizedBox(height: 30),
                      Text(
                        l10n.preview,
                        style: const TextStyle(fontSize: 22),
                      ),
                      const Divider(height: 25, indent: 20, endIndent: 20),
                      if (state.pdfDocument.value == null) ...[
                        const SizedBox(height: 30),
                        Text(
                          l10n.noCertificatesToShow,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(.25),
                            fontSize: 25,
                          ),
                        ),
                      ] else
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
