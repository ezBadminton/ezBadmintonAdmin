import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_consumer_cubit.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_filter_cubit.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/filter_predicate.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate_producers.dart';
import 'package:ez_badminton_admin_app/widgets/multi_chip/multi_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

class FilterChips<C extends PredicateConsumerCubit> extends StatelessWidget {
  const FilterChips({
    super.key,
    this.expanded = true,
  });

  final bool expanded;

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return BlocBuilder<PredicateFilterCubit, PredicateFilterState>(
      builder: (context, state) {
        Iterable<FilterPredicate> predicates =
            state.filterPredicates.values.expand((p) => p);
        Iterable<FilterPredicate> disjunctPredicates =
            predicates.where((p) => p.disjunction != null);
        Iterable<FilterPredicate> conjunctPredicates =
            predicates.where((p) => p.disjunction == null);
        Map<FilterGroup, List<FilterPredicate>> disjunctGroups =
            groupBy<FilterPredicate, FilterGroup>(
          disjunctPredicates,
          (p) => p.disjunction!,
        );
        Map<FilterGroup, List<FilterPredicate>> conjunctGroups =
            groupBy<FilterPredicate, FilterGroup>(
          conjunctPredicates,
          (p) => p.domain,
        );
        Map<FilterGroup, List<FilterPredicate>> filterGroups = conjunctGroups
          ..removeWhere((key, _) => key == FilterGroup.playerSearch)
          ..addAll(disjunctGroups);

        _joinFilterGroups(
          [FilterGroup.overAge, FilterGroup.underAge],
          filterGroups,
        );

        _joinFilterGroups(
          [FilterGroup.moreRegistrations, FilterGroup.lessRegistrations],
          filterGroups,
        );

        Widget chipWrapBuilder() => Wrap(
              children: [
                for (MapEntry<FilterGroup, List<FilterPredicate>> filterGroup
                    in filterGroups.entries)
                  _FilterGroupChip<C>(
                    filterGroupName: display_strings.filterChipGroup(
                      l10n,
                      filterGroup.key,
                    ),
                    namedFilters: {
                      for (FilterPredicate filter in filterGroup.value)
                        display_strings.filterChip(
                          l10n,
                          filter.disjunction ?? filter.domain,
                          filter.name,
                        ): filter,
                    },
                  ),
              ],
            );

        Widget chipWrap;
        if (expanded) {
          chipWrap = Expanded(child: chipWrapBuilder());
        } else {
          chipWrap = chipWrapBuilder();
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ClearFilterButton<C>(
              predicates: filterGroups.entries.expand((group) => group.value),
            ),
            chipWrap,
          ],
        );
      },
    );
  }

  void _joinFilterGroups(
    List<FilterGroup> groupsToJoin,
    Map<FilterGroup, List<FilterPredicate>> filterGroups,
  ) {
    List<FilterPredicate> filtersToJoin = filterGroups.entries
        .where(
          (entry) => groupsToJoin.contains(entry.key),
        )
        .expand((entry) => entry.value)
        .toList();
    // Remove the groups with their individual filters
    filterGroups.removeWhere(
      (key, _) => groupsToJoin.contains(key),
    );
    // Put all filters under one group
    if (filtersToJoin.isNotEmpty) {
      filterGroups.putIfAbsent(groupsToJoin.first, () => filtersToJoin);
    }
  }
}

class _ClearFilterButton<C extends PredicateConsumerCubit>
    extends StatelessWidget {
  const _ClearFilterButton({
    required this.predicates,
  });

  final Iterable<FilterPredicate> predicates;

  @override
  Widget build(BuildContext context) {
    if (predicates.isEmpty) {
      return const SizedBox();
    }
    C cubit = context.read<C>();
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return IconButton(
      onPressed: () {
        for (FilterPredicate predicate in predicates) {
          cubit.onPredicateRemoved(predicate);
        }
      },
      icon: const Icon(Icons.filter_alt_off),
      tooltip: l10n.clearFilter,
    );
  }
}

class _FilterGroupChip<C extends PredicateConsumerCubit>
    extends StatelessWidget {
  const _FilterGroupChip({
    required this.filterGroupName,
    required this.namedFilters,
  });

  final String filterGroupName;
  final Map<String, FilterPredicate> namedFilters;

  @override
  Widget build(BuildContext context) {
    C cubit = context.read<C>();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5.0,
        vertical: 3.0,
      ),
      child: MultiChip(
        title: filterGroupName,
        items: namedFilters.keys.map((filterName) => Text(filterName)).toList(),
        onDeleted: namedFilters.values
            .map(
              (p) => () {
                cubit.onPredicateRemoved(p);
              },
            )
            .toList(),
      ),
    );
  }
}
