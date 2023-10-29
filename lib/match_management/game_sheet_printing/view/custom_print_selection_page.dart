import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:ez_badminton_admin_app/input_models/list_input.dart';
import 'package:ez_badminton_admin_app/match_management/game_sheet_printing/cubit/custom_print_selection_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/match_info/match_info.dart';
import 'package:ez_badminton_admin_app/widgets/match_label/match_label.dart';
import 'package:ez_badminton_admin_app/widgets/unsaved_changes_warning/unsaved_changes_warning.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomPrintSelectionPage extends StatelessWidget {
  const CustomPrintSelectionPage({
    super.key,
    required this.initialSelection,
  });

  final List<BadmintonMatch> initialSelection;

  static Route<List<BadmintonMatch>> route(
    List<BadmintonMatch> initialSelection,
  ) {
    return MaterialPageRoute<List<BadmintonMatch>>(
      builder: (_) => CustomPrintSelectionPage(
        initialSelection: initialSelection,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var progressCubit = context.read<TournamentProgressCubit>();
    var l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => CustomPrintSelectionCubit(
        initalSelection: initialSelection,
        progressState: progressCubit.state,
      ),
      child: Builder(
        builder: (context) {
          var printSelectionCubit = context.read<CustomPrintSelectionCubit>();

          return Scaffold(
            appBar: AppBar(title: Text(l10n.selectGameSheetsToPrint)),
            body: const Align(
              alignment: AlignmentDirectional.topCenter,
              child: SizedBox(
                width: 650,
                child: _SelectionList(),
              ),
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(right: 80, bottom: 40),
              child: FloatingActionButton.extended(
                onPressed: () {
                  ListInput<BadmintonMatch> selectionInput =
                      printSelectionCubit.state.selectedMatches;
                  List<BadmintonMatch>? newSelection;
                  if (!selectionInput.isPure) {
                    newSelection = selectionInput.value;
                  }

                  Navigator.of(context).pop(newSelection);
                },
                icon: const Icon(Icons.check),
                label: Text(l10n.apply),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SelectionList extends StatelessWidget {
  const _SelectionList();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BlocBuilder<CustomPrintSelectionCubit, CustomPrintSelectionState>(
      builder: (context, state) {
        List<Widget> selectionList = _createSelectionList(state.matches, l10n);

        return BlocBuilder<CustomPrintSelectionCubit,
            CustomPrintSelectionState>(
          builder: (context, state) {
            return UnsavedChangesWarning(
              formState: state,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                children: selectionList,
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _createSelectionList(
    Map<PrintCategory, List<BadmintonMatch>> matches,
    AppLocalizations l10n,
  ) {
    Map<Widget, List<Widget>> sublists = {
      for (MapEntry<PrintCategory, List<BadmintonMatch>> matchList
          in matches.entries)
        _PrintCategoryHeader(category: matchList.key):
            _mapMatches(matchList.value),
    };

    List<Widget> selectionList = [
      for (MapEntry<Widget, List<Widget>> sublist in sublists.entries) ...[
        sublist.key,
        ...sublist.value,
      ],
    ];

    return selectionList;
  }

  List<_PrintSelectionMatchItem> _mapMatches(List<BadmintonMatch> matches) {
    return matches
        .map((match) => _PrintSelectionMatchItem(match: match))
        .toList();
  }
}

class _PrintSelectionMatchItem extends StatelessWidget {
  const _PrintSelectionMatchItem({
    required this.match,
  });

  final BadmintonMatch match;

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<CustomPrintSelectionCubit>();

    onSelect() => cubit.matchToggled(match);

    return InkWell(
      onTap: onSelect,
      child: Row(
        children: [
          const SizedBox(width: 15),
          BlocBuilder<CustomPrintSelectionCubit, CustomPrintSelectionState>(
            builder: (context, state) {
              return Checkbox(
                value: state.selectedMatches.value.contains(match),
                onChanged: (_) => onSelect(),
              );
            },
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7.0),
                side: BorderSide(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(.33),
                  width: 1,
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: MatchInfo(
                        match: match,
                        textStyle: const TextStyle(fontSize: 14),
                        playingLevelMaxWidth: 90,
                      ),
                    ),
                    MatchupLabel(match: match, participantWidth: 220),
                    Expanded(
                      child: _MatchPrintStatus(match: match),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchPrintStatus extends StatelessWidget {
  const _MatchPrintStatus({
    required this.match,
  });

  final BadmintonMatch match;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    bool created = match.matchData!.gameSheetPrinted;

    String tooltip = created ? l10n.sheetCreated : l10n.sheetNotCreated;

    IconData icon = created ? Icons.check_circle : Icons.cancel;

    Color color =
        created ? Colors.green[300]! : Theme.of(context).disabledColor;

    return Tooltip(
      message: tooltip,
      child: Center(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 11.5, bottom: 11.5),
              child: Icon(
                Icons.print,
                size: 30,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(.75),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrintCategoryHeader extends StatelessWidget {
  const _PrintCategoryHeader({
    required this.category,
  });

  final PrintCategory category;

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<CustomPrintSelectionCubit>();
    var l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () => cubit.printCategoryToggled(category),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).highlightColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                BlocBuilder<CustomPrintSelectionCubit,
                    CustomPrintSelectionState>(
                  builder: (context, state) {
                    return Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        value: state.printCategorySelectionTristates[category],
                        onChanged: (_) => cubit.printCategoryToggled(category),
                        tristate: true,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 15),
                Text(
                  l10n.printingCategory(category.toString()),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
