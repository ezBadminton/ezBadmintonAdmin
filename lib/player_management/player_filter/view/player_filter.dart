import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/player_filter/player_filter.dart';
import 'package:ez_badminton_admin_app/utils/age_groups.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_filter_cubit.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate_producers.dart';
import 'package:ez_badminton_admin_app/widgets/filter_forms/filter_forms.dart';
import 'package:ez_badminton_admin_app/widgets/filter_menu/filter_chips.dart';
import 'package:ez_badminton_admin_app/widgets/filter_menu/filter_menu.dart';
import 'package:ez_badminton_admin_app/widgets/popover_menu/popover_menu.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

class PlayerFilter extends StatelessWidget {
  const PlayerFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 1150,
      child: Column(
        children: [
          _FilterMenus(),
          SizedBox(height: 3),
          FilterChips<PlayerFilterCubit>(),
        ],
      ),
    );
  }
}

class _FilterMenus extends StatelessWidget {
  const _FilterMenus();

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return BlocConsumer<PlayerFilterCubit, PlayerFilterState>(
      listenWhen: (previous, current) {
        return current.filterPredicate != null;
      },
      listener: (context, state) {
        var listFilter = context.read<PredicateFilterCubit>();
        listFilter.consumePredicate(state.filterPredicate!);
      },
      buildWhen: (previous, current) =>
          previous.collections != current.collections,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FilterPopoverMenu(
              filterMenu:
                  PlayingLevelFilterForm<PlayerFilterCubit, PlayerFilterState>(
                playingLevels: state.getCollection<PlayingLevel>(),
                backgroudContext: context,
              ),
              buttonText: l10n.playingLevel(1),
            ),
            const SizedBox(width: 10),
            FilterPopoverMenu(
              filterMenu: _AgeFilterForm(backgroundContext: context),
              buttonText: l10n.age,
            ),
            const SizedBox(width: 10),
            FilterPopoverMenu(
              filterMenu: GenderCategoryFilterForm<PlayerFilterCubit,
                  PlayerFilterState>(
                backgroundContext: context,
              ),
              buttonText: l10n.category,
            ),
            const SizedBox(width: 10),
            FilterPopoverMenu(
              filterMenu: CompetitionTypeFilterForm<PlayerFilterCubit,
                  PlayerFilterState>(
                backgroudContext: context,
              ),
              buttonText: l10n.competition(1),
            ),
            const SizedBox(width: 10),
            FilterPopoverMenu(
              filterMenu: _StatusFilterForm(backgroudContext: context),
              buttonText: l10n.status,
            ),
            const SizedBox(width: 30),
            Expanded(child: _SearchField()),
          ],
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  _SearchField();

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    SearchPredicateProducer predicateProducer = context
        .read<PlayerFilterCubit>()
        .getPredicateProducer<SearchPredicateProducer>();
    var l10n = AppLocalizations.of(context)!;
    return BlocBuilder<PlayerFilterCubit, PlayerFilterState>(
      buildWhen: (_, current) =>
          predicateProducer.producesDomain(current.filterPredicate?.domain),
      builder: (_, __) {
        if (predicateProducer.searchTerm.isEmpty) {
          _controller.text = '';
        }
        return TextField(
          controller: _controller,
          onChanged: (searchTerm) =>
              predicateProducer.searchTermChanged(searchTerm),
          decoration: InputDecoration(
            hintText: l10n.playerSearchHint,
            prefixIcon: AnimatedRotation(
              duration: const Duration(milliseconds: 120),
              turns: predicateProducer.searchTerm.isEmpty ? 0 : -0.25,
              child: const _SearchClearButton(),
            ),
          ),
        );
      },
    );
  }
}

class _SearchClearButton extends StatelessWidget {
  const _SearchClearButton();

  @override
  Widget build(BuildContext context) {
    SearchPredicateProducer predicateProducer = context
        .read<PlayerFilterCubit>()
        .getPredicateProducer<SearchPredicateProducer>();
    return BlocBuilder<PlayerFilterCubit, PlayerFilterState>(
      buildWhen: (_, current) =>
          current.filterPredicate?.domain == FilterGroup.playerSearch,
      builder: (_, state) {
        bool searchTermPresent = predicateProducer.searchTerm.isNotEmpty;

        if (searchTermPresent) {
          return IconButton(
            onPressed: () => predicateProducer.searchTermChanged(''),
            icon: const Icon(Icons.close),
            tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
          );
        } else {
          return const Icon(Icons.search);
        }
      },
    );
  }
}

class _AgeFilterForm extends StatelessWidget {
  const _AgeFilterForm({
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
        _AgeInput(
          overAge: false,
          labelText: l10n.underAge,
          filterCubit: backgroundContext.read<PlayerFilterCubit>(),
        ),
        const SizedBox(height: 10),
        _AgeInput(
          overAge: true,
          labelText: l10n.overAge,
          filterCubit: backgroundContext.read<PlayerFilterCubit>(),
        ),
        _AgeGroupChips(backgroundContext: backgroundContext),
      ],
    );
  }
}

class _AgeGroupChips extends StatelessWidget {
  const _AgeGroupChips({
    required this.backgroundContext,
  });

  final BuildContext backgroundContext;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    PlayerFilterCubit cubit = backgroundContext.read<PlayerFilterCubit>();
    late List<AgeGroup> ageGroups = _getAgeGroups(cubit.state);
    return BlocBuilder<PlayerFilterCubit, PlayerFilterState>(
      bloc: cubit,
      builder: (context, state) {
        if (ageGroups.isEmpty) {
          return const SizedBox();
        } else {
          return Column(
            children: [
              const SizedBox(
                width: 100,
                child: Divider(
                  height: 33,
                ),
              ),
              SizedBox(
                width: ageGroups.length > 2 ? 200 : 150,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    for (AgeGroup ageGroup in ageGroups)
                      _buildAgeGroupChip(
                        l10n,
                        cubit,
                        ageGroup,
                        ageGroups,
                      ),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildAgeGroupChip(
    AppLocalizations l10n,
    PlayerFilterCubit filterCubit,
    AgeGroup ageGroup,
    List<AgeGroup> ageGroups,
  ) {
    List<int> ageRange = ageGroup.getAgeRange(ageGroups);
    AgePredicateProducer agePredicateProducer =
        filterCubit.getPredicateProducer<AgePredicateProducer>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      child: InputChip(
        label: Text(display_strings.ageGroup(l10n, ageGroup)),
        selected: _doesAgeRangeMatchFilter(ageRange, agePredicateProducer),
        onSelected: (bool selected) {
          if (selected) {
            if (ageRange[0] != 0) {
              agePredicateProducer.overAgeChanged('${ageRange[0]}');
            } else {
              agePredicateProducer.overAgeChanged('');
            }
            if (ageRange[1] != 999) {
              agePredicateProducer.underAgeChanged('${ageRange[1] + 1}');
            } else {
              agePredicateProducer.underAgeChanged('');
            }
          } else {
            agePredicateProducer.overAgeChanged('');
            agePredicateProducer.underAgeChanged('');
          }
          agePredicateProducer.produceAgePredicates();
        },
      ),
    );
  }

  bool _doesAgeRangeMatchFilter(
    List<int> ageRange,
    AgePredicateProducer agePredicateProducer,
  ) {
    int? currentOverAge = int.tryParse(agePredicateProducer.overAge);
    int? currentUnderAge = int.tryParse(agePredicateProducer.underAge);
    bool filterMatchesLowerBound = ageRange[0] == 0;
    if (currentOverAge != null) {
      filterMatchesLowerBound = ageRange[0] == currentOverAge;
    }
    bool filterMatchesUpperBound = ageRange[1] == 999;
    if (currentUnderAge != null) {
      // +1 because the age range is inclusive while an under age value of n
      // means before n-th birthday.
      filterMatchesUpperBound = ageRange[1] + 1 == currentUnderAge;
    }
    bool isSelected = filterMatchesLowerBound && filterMatchesUpperBound;
    return isSelected;
  }

  List<AgeGroup> _getAgeGroups(PlayerFilterState filterState) {
    List<AgeGroup> sortedAgeGroups =
        filterState.getCollection<AgeGroup>().sorted(
      (a, b) {
        int comparison = a.age.compareTo(b.age);
        if (comparison == 0) {
          comparison = a.type == AgeGroupType.over ? 1 : -1;
        }
        return comparison;
      },
    );
    return sortedAgeGroups;
  }
}

class _StatusFilterForm extends StatelessWidget {
  const _StatusFilterForm({
    required this.backgroudContext,
  });

  final BuildContext backgroudContext;

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    PlayerFilterCubit cubit = backgroudContext.read<PlayerFilterCubit>();
    StatusPredicateProducer predicateProducer =
        cubit.getPredicateProducer<StatusPredicateProducer>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: PlayerStatus.values
          .map(
            (playerStatus) => FilterCheckbox<PlayerFilterCubit,
                PlayerFilterState, PlayerStatus>(
              backgroundContext: backgroudContext,
              checkboxValue: playerStatus,
              predicateProducer: predicateProducer,
              toggledValuesGetter: () => predicateProducer.statusList,
              onToggle: predicateProducer.statusToggled,
              label: l10n.playerStatus(playerStatus.name),
            ),
          )
          .toList(),
    );
  }
}

class _AgeInput extends StatelessWidget {
  _AgeInput({
    required this.overAge,
    required this.labelText,
    required this.filterCubit,
  })  : _focusNode = FocusNode(),
        _controller = TextEditingController() {
    var predicateProducer =
        filterCubit.getPredicateProducer<AgePredicateProducer>();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        predicateProducer.produceAgePredicates();
      }
    });
    _controller.text =
        overAge ? predicateProducer.overAge : predicateProducer.underAge;
    if (!overAge) {
      _focusNode.requestFocus();
    }
  }

  final bool overAge;
  final String labelText;
  final PlayerFilterCubit filterCubit;
  final FocusNode _focusNode;
  final TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    var predicateProducer =
        filterCubit.getPredicateProducer<AgePredicateProducer>();
    return BlocConsumer<PlayerFilterCubit, PlayerFilterState>(
      bloc: filterCubit,
      listenWhen: (_, current) =>
          predicateProducer.producesDomain(current.filterPredicate?.domain),
      listener: (context, state) {
        _controller.text =
            overAge ? predicateProducer.overAge : predicateProducer.underAge;
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
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 40),
                  child: SizedBox(
                    child: Text(
                      labelText,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 30,
                  child: TextField(
                    controller: _controller,
                    onChanged: overAge
                        ? (age) => predicateProducer.overAgeChanged(age)
                        : (age) => predicateProducer.underAgeChanged(age),
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
              ],
            ),
          ),
        );
      },
    );
  }
}
