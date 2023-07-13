import 'package:collection_repository/collection_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_editing/cubit/competition_adding_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/models/competition_category.dart';
import 'package:ez_badminton_admin_app/widgets/implicit_animated_list/implicit_animated_list.dart';
import 'package:ez_badminton_admin_app/widgets/long_tooltip/long_tooltip.dart';
import 'package:ez_badminton_admin_app/widgets/mouse_hover_builder/mouse_hover_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

class CompetitionAdditionPreview extends StatelessWidget {
  // A widget for displaying the list of competitions that will be added upon
  // submitting the competition creation form in its current state.
  const CompetitionAdditionPreview({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return BlocBuilder<CompetitionAddingCubit, CompetitionAddingState>(
      builder: (context, state) {
        bool useAgeGroups =
            state.getCollection<Tournament>().first.useAgeGroups;
        bool usePlayingLevels =
            state.getCollection<Tournament>().first.usePlayingLevels;
        bool noCategories = !useAgeGroups && !usePlayingLevels;

        List<_CategoryTuple> previewList = _buildPreviewList(
          useAgeGroups,
          usePlayingLevels,
          state.ageGroups,
          state.playingLevels,
          state.competitionCategories,
        );

        int numNewCategories =
            state.ageGroups.length * state.playingLevels.length;
        int numBaseDisciplines = state.competitionCategories.length;
        int numNewCompetitions = numNewCategories * numBaseDisciplines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  noCategories
                      ? l10n.newCompetitions(numNewCompetitions)
                      : l10n.newCategories(numNewCategories),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!noCategories && numNewCategories > 0) ...[
                  const SizedBox(width: 7),
                  LongTooltip(
                    message: _getHelpMessage(
                      l10n,
                      useAgeGroups,
                      usePlayingLevels,
                      numNewCategories,
                      numBaseDisciplines,
                    ),
                    child: Icon(
                      Icons.help_outline,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(.5),
                      size: 21,
                    ),
                  ),
                ],
              ],
            ),
            if (!noCategories)
              Text(
                l10n.totalNewCompetitions(numNewCompetitions),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).disabledColor,
                ),
              ),
            const SizedBox(height: 20),
            _PreviewListHeader(
              useAgeGroups: useAgeGroups,
              usePlayingLevels: usePlayingLevels,
            ),
            SizedBox(
              height: 160,
              child: ImplicitAnimatedList<_CategoryTuple>(
                elements: previewList,
                itemBuilder: (context, element, animation) {
                  return SizeTransition(
                    sizeFactor: animation,
                    child: _PreviewListItem(element),
                  );
                },
                duration: const Duration(milliseconds: 120),
                elementsEqual: (element1, element2) {
                  return element1.ageGroup == element2.ageGroup &&
                      element1.playingLevel == element2.playingLevel &&
                      element1.baseCategories.length ==
                          element2.baseCategories.length;
                },
              ),
            ),
          ],
        );
      },
    );
  }

  static List<_CategoryTuple> _buildPreviewList(
    bool useAgeGroups,
    bool usePlayingLevels,
    List<AgeGroup> selectedAgeGroups,
    List<PlayingLevel> selectedPlayingLevels,
    List<CompetitionCategory> selectedCompetitionCategories,
  ) {
    if (selectedCompetitionCategories.isEmpty) {
      return [];
    }

    List<AgeGroup?> ageGroups = useAgeGroups ? selectedAgeGroups : [null];
    List<PlayingLevel?> playingLevels =
        usePlayingLevels ? selectedPlayingLevels : [null];

    List<_CategoryTuple> items = [
      for (AgeGroup? ageGroup in ageGroups)
        for (PlayingLevel? playingLevel in playingLevels) ...[
          _CategoryTuple(
            ageGroup: ageGroup,
            playingLevel: playingLevel,
            baseCategories: selectedCompetitionCategories,
          ),
        ],
    ];

    return items;
  }

  static String _getHelpMessage(
    AppLocalizations l10n,
    bool useAgeGroups,
    bool usePlayingLevels,
    int numNewCategories,
    int numBaseDisciplines,
  ) {
    assert(useAgeGroups || usePlayingLevels);
    String categories = '';
    if (useAgeGroups && usePlayingLevels) {
      categories = l10n.combinationsOf(
        l10n.ageGroup(2),
        l10n.playingLevel(2),
      );
    } else if (useAgeGroups) {
      categories = l10n.ageGroup(2);
    } else if (usePlayingLevels) {
      categories = l10n.playingLevel(2);
    }

    String helpMessage = l10n.competitionAddingTooltip(
      numBaseDisciplines,
      categories,
      numNewCategories,
    );

    return helpMessage;
  }
}

class _PreviewListHeader extends StatelessWidget {
  const _PreviewListHeader({
    required this.useAgeGroups,
    required this.usePlayingLevels,
  });

  final bool useAgeGroups;
  final bool usePlayingLevels;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return DefaultTextStyle(
      style: Theme.of(context)
          .textTheme
          .bodyMedium!
          .copyWith(fontWeight: FontWeight.w600),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: const Border(
            bottom: BorderSide(
              color: Colors.black26,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Row(
            children: [
              const SizedBox(width: 20),
              if (useAgeGroups) ...[
                SizedBox(
                  width: 200,
                  child: Text(l10n.ageGroup(1)),
                ),
                Flexible(
                  flex: 1,
                  child: Container(),
                ),
              ],
              if (usePlayingLevels) ...[
                SizedBox(
                  width: 300,
                  child: Text(l10n.playingLevel(1)),
                ),
                Flexible(
                  flex: 1,
                  child: Container(),
                ),
              ],
              SizedBox(
                width: 200,
                child: Text(l10n.baseCompetition(2)),
              ),
              Flexible(
                flex: 10,
                child: Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewListItem extends StatelessWidget {
  const _PreviewListItem(
    this.categoryTuple,
  );

  final _CategoryTuple categoryTuple;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    AgeGroup? ageGroup = categoryTuple.ageGroup;
    PlayingLevel? playingLevel = categoryTuple.playingLevel;

    return MouseHoverBuilder(
      builder: (context, isHovered) => Container(
        color: isHovered ? Theme.of(context).hoverColor : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.0),
          child: Row(
            children: [
              const SizedBox(width: 20),
              if (ageGroup != null) ...[
                SizedBox(
                  width: 200,
                  child: Text(display_strings.ageGroup(l10n, ageGroup)),
                ),
                Flexible(
                  flex: 1,
                  child: Container(),
                ),
              ],
              if (playingLevel != null) ...[
                SizedBox(
                  width: 300,
                  child: Text(playingLevel.name),
                ),
                Flexible(
                  flex: 1,
                  child: Container(),
                ),
              ],
              SizedBox(
                width: 200,
                child: Text(_competitionCategoryListToString(l10n)),
              ),
              Flexible(
                flex: 10,
                child: Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _competitionCategoryListToString(AppLocalizations l10n) {
    String categoryList = categoryTuple.baseCategories
        .map((c) => display_strings.competitionCategoryAbbreviation(l10n, c))
        .join(', ');

    return categoryList;
  }
}

class _CategoryTuple extends Equatable {
  /// A tuple of [ageGroup] and [playingLevel] forming a playing category.
  ///
  /// The [baseCategories] list contains the [CompetitionCategory]s that are
  /// available in this category.
  const _CategoryTuple({
    required this.ageGroup,
    required this.playingLevel,
    required this.baseCategories,
  });

  final AgeGroup? ageGroup;
  final PlayingLevel? playingLevel;
  final List<CompetitionCategory> baseCategories;

  @override
  List<Object?> get props => [ageGroup, playingLevel];
}
