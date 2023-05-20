import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/player_filter/player_filter.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_filter_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/popover_menu/popover_menu.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlayerFilter extends StatelessWidget {
  const PlayerFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1150,
      child: Column(
        children: const [
          _FilterMenus(),
          SizedBox(height: 10),
          _FilterChips(),
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
    return BlocListener<PlayerFilterCubit, PlayerFilterState>(
      listenWhen: (_, current) => current.filterPredicate != null,
      listener: (context, state) {
        var listFilter = context.read<PredicateFilterCubit>();
        listFilter.consumePredicate(state.filterPredicate!);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FilterPopoverMenu(
            filterMenu: _AgeFilterForm(backgroundContext: context),
            buttonText: l10n.age,
          ),
          const SizedBox(width: 10),
          FilterPopoverMenu(
            filterMenu: _GenderFilterForm(backgroundContext: context),
            buttonText: l10n.gender,
          ),
          const SizedBox(width: 10),
          FilterPopoverMenu(
            filterMenu: _PlayingLevelFilterForm(backgroudContext: context),
            buttonText: l10n.playingLevel,
          ),
          const SizedBox(width: 10),
          FilterPopoverMenu(
            filterMenu: _CompetitionFilterForm(backgroudContext: context),
            buttonText: l10n.competition,
          ),
          const SizedBox(width: 30),
          Expanded(child: _SearchField()),
        ],
      ),
    );
  }
}

class _PlayingLevelFilterForm extends StatelessWidget {
  const _PlayingLevelFilterForm({
    required this.backgroudContext,
  });

  final BuildContext backgroudContext;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerFilterCubit, PlayerFilterState>(
      bloc: backgroudContext.read<PlayerFilterCubit>(),
      buildWhen: (previous, current) =>
          previous.allPlayingLevels != current.allPlayingLevels,
      builder: (_, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: state.allPlayingLevels
              .map(
                (playingLevel) => _PlayingLevelCheckbox(
                  playingLevel: playingLevel,
                  filterCubit: backgroudContext.read<PlayerFilterCubit>(),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _CompetitionFilterForm extends StatelessWidget {
  const _CompetitionFilterForm({
    required this.backgroudContext,
  });

  final BuildContext backgroudContext;

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: CompetitionType.values
          .map(
            (competitionType) => _CompetitionCheckbox(
              competition: competitionType,
              label: l10n.competitionType(competitionType.name),
              filterCubit: backgroudContext.read<PlayerFilterCubit>(),
            ),
          )
          .toList(),
    );
  }
}

class _PlayingLevelCheckbox extends StatelessWidget {
  const _PlayingLevelCheckbox({
    required this.playingLevel,
    required this.filterCubit,
  });

  final PlayingLevel playingLevel;
  final PlayerFilterCubit filterCubit;

  @override
  Widget build(BuildContext context) {
    var predicateProducer =
        filterCubit.getPredicateProducer<PlayingLevelPredicateProducer>()!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BlocBuilder<PlayerFilterCubit, PlayerFilterState>(
          bloc: filterCubit,
          buildWhen: (_, current) =>
              current.filterPredicate != null &&
              predicateProducer.producesDomain(current.filterPredicate!.domain),
          builder: (_, __) {
            return Checkbox(
              value: predicateProducer.playingLevels.contains(playingLevel),
              onChanged: (value) {
                predicateProducer.playingLevelToggled(playingLevel);
              },
            );
          },
        ),
        Center(
          child: Text(
            playingLevel.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _CompetitionCheckbox extends StatelessWidget {
  const _CompetitionCheckbox({
    required this.competition,
    required this.label,
    required this.filterCubit,
  });

  final CompetitionType competition;
  final String label;
  final PlayerFilterCubit filterCubit;

  @override
  Widget build(BuildContext context) {
    var predicateProducer =
        filterCubit.getPredicateProducer<CompetitionTypePredicateProducer>()!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BlocBuilder<PlayerFilterCubit, PlayerFilterState>(
          bloc: filterCubit,
          buildWhen: (_, current) =>
              current.filterPredicate != null &&
              predicateProducer.producesDomain(current.filterPredicate!.domain),
          builder: (_, __) {
            return Checkbox(
              value: predicateProducer.competitionTypes.contains(competition),
              onChanged: (value) {
                predicateProducer.competitionTypeToggled(competition);
              },
            );
          },
        ),
        Center(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  _SearchField();

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var predicateProducer = context
        .read<PlayerFilterCubit>()
        .getPredicateProducer<SearchPredicateProducer>()!;
    var l10n = AppLocalizations.of(context)!;
    return BlocBuilder<PlayerFilterCubit, PlayerFilterState>(
      buildWhen: (_, current) => predicateProducer.searchTerm.isEmpty,
      builder: (_, __) {
        _controller.text = predicateProducer.searchTerm;
        return TextField(
          controller: _controller,
          onChanged: (searchTerm) =>
              predicateProducer.searchTermChanged(searchTerm),
          decoration: InputDecoration(
            hintText: l10n.playerSearchHint,
            prefixIcon: const Icon(Icons.search),
          ),
        );
      },
    );
  }
}

class _GenderFilterForm extends StatelessWidget {
  const _GenderFilterForm({
    required this.backgroundContext,
  });

  final BuildContext backgroundContext;

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GenderButton(
            labelText: l10n.women,
            gender: Gender.female,
            filterCubit: backgroundContext.read<PlayerFilterCubit>(),
          ),
          const SizedBox(height: 10),
          _GenderButton(
            labelText: l10n.men,
            gender: Gender.male,
            filterCubit: backgroundContext.read<PlayerFilterCubit>(),
          ),
        ],
      ),
    );
  }
}

class _GenderButton extends StatelessWidget {
  const _GenderButton({
    required this.labelText,
    required this.gender,
    required this.filterCubit,
  });

  final String labelText;
  final Gender gender;
  final PlayerFilterCubit filterCubit;

  @override
  Widget build(BuildContext context) {
    var predicateProducer =
        filterCubit.getPredicateProducer<GenderPredicateProducer>()!;
    return BlocBuilder<PlayerFilterCubit, PlayerFilterState>(
      bloc: filterCubit,
      buildWhen: (_, current) =>
          current.filterPredicate != null &&
          predicateProducer.producesDomain(current.filterPredicate!.domain),
      builder: (_, __) {
        var buttonBackgroundColor = predicateProducer.gender == gender
            ? MaterialStateProperty.all(Theme.of(context).colorScheme.primary)
            : MaterialStateProperty.all(Theme.of(context).colorScheme.surface);
        var buttonTextColor = predicateProducer.gender == gender
            ? MaterialStateProperty.all(Theme.of(context).colorScheme.onPrimary)
            : MaterialStateProperty.all(
                Theme.of(context).colorScheme.onSurface);
        var buttonBorder = predicateProducer.gender == gender
            ? BorderSide(color: Theme.of(context).primaryColor)
            : BorderSide(color: Theme.of(context).disabledColor);
        return ElevatedButton(
          onPressed: () {
            predicateProducer.genderChanged(gender);
            PopoverMenu.of(context).close();
          },
          style: ButtonStyle(
            shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
                side: buttonBorder,
              ),
            ),
            backgroundColor: buttonBackgroundColor,
            foregroundColor: buttonTextColor,
          ),
          child: Text(labelText),
        );
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
      ],
    );
  }
}

class FilterPopoverMenu extends StatelessWidget {
  const FilterPopoverMenu({
    super.key,
    required this.filterMenu,
    required this.buttonText,
  });

  final String buttonText;
  final Widget filterMenu;

  @override
  Widget build(BuildContext context) {
    return PopoverMenuButton(
      menu: Card(
        margin: const EdgeInsets.all(0.0),
        color: Theme.of(context).cardColor,
        elevation: 6.0,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Theme.of(context).colorScheme.background,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: filterMenu,
        ),
      ),
      label: Text(buttonText),
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
        filterCubit.getPredicateProducer<AgePredicateProducer>()!;
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
        filterCubit.getPredicateProducer<AgePredicateProducer>()!;
    return BlocBuilder<PlayerFilterCubit, PlayerFilterState>(
      bloc: filterCubit,
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
                    key: Key(
                      'ageFilterForm_${overAge ? 'over' : 'under'}AgeInput_textField',
                    ),
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

class _FilterChips extends StatelessWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PredicateFilterCubit, PredicateFilterState>(
      builder: (context, state) {
        return Wrap(
          children: state.filterPredicates.values
              .expand((e) => e)
              .map((predicate) => Chip(
                    label: Text(predicate.name),
                    onDeleted: () {
                      context
                          .read<PlayerFilterCubit>()
                          .onPredicateRemoved(predicate);
                    },
                  ))
              .toList(),
        );
      },
    );
  }
}
