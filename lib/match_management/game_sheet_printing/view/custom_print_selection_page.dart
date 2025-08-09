import 'package:ez_badminton_admin_app/widgets/tournament_context/tournament_context.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/input_models/list_input.dart';
import 'package:ez_badminton_admin_app/match_management/game_sheet_printing/cubit/custom_print_selection_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/player_filter/player_filter.dart';
import 'package:ez_badminton_admin_app/player_management/player_filter/view/player_filter.dart';
import 'package:ez_badminton_admin_app/predicate_filter/common_predicate_producers/agegroup_predicate_producer.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_filter_cubit.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate_producers.dart';
import 'package:ez_badminton_admin_app/widgets/filter_menu/filter_chips.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:ez_badminton_admin_app/widgets/match_info/match_info.dart';
import 'package:ez_badminton_admin_app/widgets/match_label/match_label.dart';
import 'package:ez_badminton_admin_app/widgets/unsaved_changes_warning/unsaved_changes_warning.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ez_badminton_admin_app/l10n/l10n.dart';
import 'package:flutter_scroll_shadow/flutter_scroll_shadow.dart';

class CustomPrintSelectionPage extends StatelessWidget {
  const CustomPrintSelectionPage({
    super.key,
    required this.initialSelection,
  });

  final List<MatchContext> initialSelection;

  static Route<List<MatchContext>> route(
    List<MatchContext> initialSelection,
  ) {
    return MaterialPageRoute<List<MatchContext>>(
      builder: (_) => CustomPrintSelectionPage(
        initialSelection: initialSelection,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CustomPrintSelectionCubit(
            scheduledMatchStore: context.read<ModelStore<ScheduledMatch>>(),
            scheduledRoundStore: context.read<ModelStore<ScheduledRound>>(),
            initalSelection: initialSelection,
          ),
        ),
        BlocProvider(create: (context) => PredicateFilterCubit()),
        BlocProvider(
          create: (_) => PlayerFilterCubit(
            ageGroupPredicateProducer: AgeGroupPredicateProducer(),
            genderPredicateProducer: GenderCategoryPredicateProducer(),
            playingLevelPredicateProducer: PlayingLevelPredicateProducer(),
            competitionTypePredicateProducer:
                CompetitionTypePredicateProducer(),
            statusPredicateProducer: StatusPredicateProducer(),
            searchPredicateProducer: SearchPredicateProducer(),
            playingLevelStore: context.read<ModelStore<PlayingLevel>>(),
            ageGroupStore: context.read<ModelStore<AgeGroup>>(),
            tournamentStore: context.read<ModelStore<TournamentEvent>>(),
          ),
        ),
      ],
      child: const _CustomPrintSelectionPageScaffold(),
    );
  }
}

class _CustomPrintSelectionPageScaffold extends StatelessWidget {
  const _CustomPrintSelectionPageScaffold();

  @override
  Widget build(BuildContext context) {
    var printSelectionCubit = context.read<CustomPrintSelectionCubit>();
    var l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.selectGameSheetsToPrint)),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 80, bottom: 40),
        child: FloatingActionButton.extended(
          onPressed: () {
            ListInput<MatchContext> selectionInput =
                printSelectionCubit.state.selectedMatches;
            List<MatchContext>? newSelection;
            if (!selectionInput.isPure) {
              newSelection = selectionInput.value;
            }

            Navigator.of(context).pop(newSelection);
          },
          icon: const Icon(Icons.check),
          label: Text(l10n.apply),
        ),
      ),
      body: BlocBuilder<PlayerFilterCubit, PlayerFilterState>(
        builder: (context, state) {
          return LoadingScreen(
            loadingStatus: state.loadingStatus,
            builder: (context) => const Align(
              alignment: AlignmentDirectional.topCenter,
              child: SizedBox(
                width: 1000,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    _SelectionFilter(),
                    Expanded(
                      child: SizedBox(
                        width: 680,
                        child: _SelectionList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SelectionFilter extends StatelessWidget {
  const _SelectionFilter();

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<CustomPrintSelectionCubit>();

    return BlocListener<PredicateFilterCubit, PredicateFilterState>(
      listener: (context, state) {
        cubit.filterChanged(state.filters);
      },
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PlayerFilterMenus(useStatusFilter: false),
          SizedBox(height: 3),
          FilterChips<PlayerFilterCubit, PredicateFilterCubit>(expanded: false),
        ],
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
              child: ScrollShadow(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 200),
                  children: selectionList,
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _createSelectionList(
    Map<PrintCategory, List<MatchContext>> matches,
    AppLocalizations l10n,
  ) {
    Map<Widget, List<Widget>> sublists = {
      for (MapEntry<PrintCategory, List<MatchContext>> matchList
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

  List<Widget> _mapMatches(List<MatchContext> matches) {
    return matches
        .map(
          (mContext) => TournamentMatchContextSubtree.fromContext(
            key: ValueKey('PrintSelectionMatch-${mContext.match.id}'),
            context: mContext,
            child: _PrintSelectionMatchItem(),
          ),
        )
        .toList();
  }
}

class _PrintSelectionMatchItem extends StatelessWidget {
  const _PrintSelectionMatchItem();

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<CustomPrintSelectionCubit>();

    var mContext = context.readMatchContext();

    onSelect() => cubit.matchToggled(mContext);

    return InkWell(
      onTap: onSelect,
      child: Row(
        children: [
          const SizedBox(width: 15),
          BlocBuilder<CustomPrintSelectionCubit, CustomPrintSelectionState>(
            builder: (context, state) {
              return Checkbox(
                value: state.selectedMatches.value.contains(mContext),
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
                        textStyle: const TextStyle(fontSize: 14),
                        playingLevelMaxWidth: 90,
                      ),
                    ),
                    MatchupLabel(
                      participantWidth: 250,
                      useFullName: true,
                      boldLastName: true,
                    ),
                    Expanded(
                      child: _MatchPrintStatus(),
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
  const _MatchPrintStatus();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    var match = context.readMatch();
    bool created = match.gameSheetPrinted;

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
