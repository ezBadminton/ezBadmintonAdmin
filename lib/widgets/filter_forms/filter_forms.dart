import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_filter/competition_filter.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_consumer_cubit.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_consumer_state.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate_producers.dart';
import 'package:ez_badminton_admin_app/widgets/filter_menu/filter_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

class AgeGroupFilterForm<C extends PredicateConsumerCubit<S>,
    S extends PredicateConsumerState> extends StatelessWidget {
  const AgeGroupFilterForm({
    super.key,
    required this.backgroudContext,
    required this.ageGroups,
  });

  final BuildContext backgroudContext;
  final List<AgeGroup> ageGroups;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    C cubit = backgroudContext.read<C>();
    AgeGroupPredicateProducer predicateProducer =
        cubit.getPredicateProducer<AgeGroupPredicateProducer>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ageGroups
          .map(
            (ageGroup) => FilterCheckbox<C, S, AgeGroup>(
              backgroundContext: backgroudContext,
              checkboxValue: ageGroup,
              predicateProducer: predicateProducer,
              toggledValuesGetter: () => predicateProducer.ageGroups,
              onToggle: predicateProducer.ageGroupToggled,
              label: display_strings.ageGroup(l10n, ageGroup),
            ),
          )
          .toList(),
    );
  }
}

class PlayingLevelFilterForm<C extends PredicateConsumerCubit<S>,
    S extends PredicateConsumerState> extends StatelessWidget {
  const PlayingLevelFilterForm({
    super.key,
    required this.backgroudContext,
    required this.playingLevels,
  });

  final BuildContext backgroudContext;
  final List<PlayingLevel> playingLevels;

  @override
  Widget build(BuildContext context) {
    C cubit = backgroudContext.read<C>();
    PlayingLevelPredicateProducer predicateProducer =
        cubit.getPredicateProducer<PlayingLevelPredicateProducer>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: playingLevels
          .map(
            (playingLevel) => FilterCheckbox<C, S, PlayingLevel>(
              backgroundContext: backgroudContext,
              checkboxValue: playingLevel,
              predicateProducer: predicateProducer,
              toggledValuesGetter: () => predicateProducer.playingLevels,
              onToggle: predicateProducer.playingLevelToggled,
              label: playingLevel.name,
            ),
          )
          .toList(),
    );
  }
}

class GenderCategoryFilterForm<C extends PredicateConsumerCubit<S>,
    S extends PredicateConsumerState> extends StatelessWidget {
  const GenderCategoryFilterForm({
    super.key,
    required this.backgroundContext,
  });

  final BuildContext backgroundContext;

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    C cubit = backgroundContext.read<C>();
    GenderCategoryPredicateProducer predicateProducer =
        cubit.getPredicateProducer<GenderCategoryPredicateProducer>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (GenderCategory category in [
          GenderCategory.female,
          GenderCategory.male,
        ]) ...[
          FilterCheckbox<C, S, GenderCategory>(
            backgroundContext: backgroundContext,
            label: l10n.genderCategory(category.name),
            checkboxValue: category,
            onToggle: predicateProducer.categoryToggled,
            predicateProducer: predicateProducer,
            toggledValuesGetter: () => predicateProducer.categories,
          ),
          if (category != GenderCategory.male) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class CompetitionTypeFilterForm<C extends PredicateConsumerCubit<S>,
    S extends PredicateConsumerState> extends StatelessWidget {
  const CompetitionTypeFilterForm({
    super.key,
    required this.backgroudContext,
  });

  final BuildContext backgroudContext;

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    C cubit = backgroudContext.read<C>();
    CompetitionTypePredicateProducer predicateProducer =
        cubit.getPredicateProducer<CompetitionTypePredicateProducer>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: CompetitionType.values
          .map(
            (competitionType) => FilterCheckbox<C, S, CompetitionType>(
              backgroundContext: backgroudContext,
              checkboxValue: competitionType,
              predicateProducer: predicateProducer,
              toggledValuesGetter: () => predicateProducer.competitionTypes,
              onToggle: predicateProducer.competitionTypeToggled,
              label: l10n.competitionType(competitionType.name),
            ),
          )
          .toList(),
    );
  }
}
