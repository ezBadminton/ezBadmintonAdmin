import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_filter/cubit/competition_filter_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_filter/registration_count_predicate_producer.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_filter_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/filter_forms/filter_forms.dart';
import 'package:ez_badminton_admin_app/widgets/filter_menu/filter_chips.dart';
import 'package:ez_badminton_admin_app/widgets/filter_menu/filter_menu.dart';
import 'package:ez_badminton_admin_app/widgets/popover_menu/popover_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompetitionFilter extends StatelessWidget {
  const CompetitionFilter({
    super.key,
    this.expanded = true,
  });

  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CompetitionFilterMenus(),
        const SizedBox(height: 3),
        FilterChips<CompetitionFilterCubit>(expanded: expanded),
      ],
    );
  }
}

class CompetitionFilterMenus extends StatelessWidget {
  const CompetitionFilterMenus({
    super.key,
    this.useAgeGroupFilter = true,
    this.usePlayingLevelFilter = true,
    this.useGenderCategoryFilter = true,
    this.useCompetitionTypeFilter = true,
    this.useRegistrationCountFilter = true,
  });

  final bool useAgeGroupFilter;
  final bool usePlayingLevelFilter;
  final bool useGenderCategoryFilter;
  final bool useCompetitionTypeFilter;
  final bool useRegistrationCountFilter;

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return BlocConsumer<CompetitionFilterCubit, CompetitionFilterState>(
      listenWhen: (_, current) => current.filterPredicate != null,
      listener: (context, state) {
        var listFilter = context.read<PredicateFilterCubit>();
        listFilter.consumePredicate(state.filterPredicate!);
      },
      buildWhen: (previous, current) =>
          previous.collections != current.collections,
      builder: (context, state) {
        Tournament tournament = state.getCollection<Tournament>().first;
        bool showAgeGroupFilter = tournament.useAgeGroups;
        bool showPlayingLevelFilter = tournament.usePlayingLevels;
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showAgeGroupFilter && useAgeGroupFilter) ...[
              FilterPopoverMenu(
                filterMenu: AgeGroupFilterForm<CompetitionFilterCubit,
                    CompetitionFilterState>(
                  ageGroups: state.getCollection<AgeGroup>(),
                  backgroundContext: context,
                ),
                buttonText: l10n.ageGroup(1),
              ),
              const SizedBox(width: 10),
            ],
            if (showPlayingLevelFilter && usePlayingLevelFilter) ...[
              FilterPopoverMenu(
                filterMenu: PlayingLevelFilterForm<CompetitionFilterCubit,
                    CompetitionFilterState>(
                  playingLevels: state.getCollection<PlayingLevel>(),
                  backgroudContext: context,
                ),
                buttonText: l10n.playingLevel(1),
              ),
              const SizedBox(width: 10),
            ],
            if (useGenderCategoryFilter) ...[
              FilterPopoverMenu(
                filterMenu: GenderCategoryFilterForm<CompetitionFilterCubit,
                    CompetitionFilterState>(
                  backgroundContext: context,
                ),
                buttonText: l10n.category,
              ),
              const SizedBox(width: 10),
            ],
            if (useCompetitionTypeFilter) ...[
              FilterPopoverMenu(
                filterMenu: CompetitionTypeFilterForm<CompetitionFilterCubit,
                    CompetitionFilterState>(
                  backgroudContext: context,
                ),
                buttonText: l10n.competition(1),
              ),
              const SizedBox(width: 10),
            ],
            if (useRegistrationCountFilter)
              FilterPopoverMenu(
                filterMenu: _RegistrationCountFilterForm(
                  backgroundContext: context,
                ),
                buttonText: l10n.registrations,
              ),
          ],
        );
      },
    );
  }
}

class _RegistrationCountFilterForm extends StatelessWidget {
  const _RegistrationCountFilterForm({
    required this.backgroundContext,
  });

  final BuildContext backgroundContext;

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _RegistrationCountInput(
          moreThan: true,
          labelText: l10n.orMore,
          filterCubit: backgroundContext.read<CompetitionFilterCubit>(),
        ),
        const SizedBox(height: 10),
        _RegistrationCountInput(
          moreThan: false,
          labelText: l10n.orLess,
          filterCubit: backgroundContext.read<CompetitionFilterCubit>(),
        ),
      ],
    );
  }
}

class _RegistrationCountInput extends StatelessWidget {
  _RegistrationCountInput({
    required this.moreThan,
    required this.labelText,
    required this.filterCubit,
  })  : _focusNode = FocusNode(),
        _controller = TextEditingController() {
    var predicateProducer =
        filterCubit.getPredicateProducer<RegistrationCountPredicateProducer>();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        predicateProducer.produceRegistrationCountPredicates();
      }
    });
    _controller.text =
        moreThan ? predicateProducer.overCount : predicateProducer.underCount;
    if (moreThan) {
      _focusNode.requestFocus();
    }
  }

  final bool moreThan;
  final String labelText;
  final CompetitionFilterCubit filterCubit;
  final FocusNode _focusNode;
  final TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    var predicateProducer =
        filterCubit.getPredicateProducer<RegistrationCountPredicateProducer>();
    return BlocConsumer<CompetitionFilterCubit, CompetitionFilterState>(
      bloc: filterCubit,
      listenWhen: (_, current) =>
          predicateProducer.producesDomain(current.filterPredicate?.domain),
      listener: (context, state) {
        _controller.text = moreThan
            ? predicateProducer.overCount
            : predicateProducer.underCount;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      },
      buildWhen: (_, current) =>
          predicateProducer.producesDomain(current.filterPredicate?.domain),
      builder: (context, state) {
        return Card(
          margin: EdgeInsets.zero,
          color: Theme.of(context).primaryColor,
          shape: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 30,
                  child: TextField(
                    controller: _controller,
                    onChanged: moreThan
                        ? (count) =>
                            predicateProducer.overRegistrationsChanged(count)
                        : (count) =>
                            predicateProducer.underRegistrationsChanged(count),
                    onSubmitted: (_) => PopoverMenu.of(context).close(),
                    focusNode: _focusNode,
                    textAlignVertical: TextAlignVertical.top,
                    cursorColor: Theme.of(context).colorScheme.onPrimary,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(2),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor:
                          HSLColor.fromColor(Theme.of(context).primaryColor)
                              .withLightness(.65)
                              .toColor(),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 7),
                      isDense: true,
                      enabledBorder:
                          const OutlineInputBorder(borderSide: BorderSide.none),
                      focusedBorder:
                          const OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 95),
                  child: SizedBox(
                    child: Text(
                      labelText,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
