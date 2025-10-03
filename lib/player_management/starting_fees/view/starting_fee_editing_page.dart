import 'package:ez_badminton_admin_app/competition_management/competition_sorter/comparators/competition_comparator.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_sorter/cubit/competition_sorting_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_list_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/models/competition_category.dart';
import 'package:ez_badminton_admin_app/competition_management/view/competition_list.dart';
import 'package:ez_badminton_admin_app/competition_management/view/competition_selection_options.dart';
import 'package:ez_badminton_admin_app/l10n/l10n.dart';
import 'package:ez_badminton_admin_app/list_selection/cubit/model_selection_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/starting_fees/cubit/starting_fee_currency_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/starting_fees/cubit/starting_fee_editing_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/starting_fees/cubit/mass_discount_editing_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/starting_fees/currency_utils.dart';
import 'package:ez_badminton_admin_app/widgets/currency_input/currency_input.dart';
import 'package:ez_badminton_admin_app/widgets/currency_input/currency_selection_dialog.dart';
import 'package:ez_badminton_admin_app/widgets/help_tooltip_icon/help_tooltip_icon.dart';
import 'package:ez_badminton_admin_app/widgets/implicit_animated_list/implicit_animated_list.dart';
import 'package:ez_badminton_admin_app/widgets/integer_stepper/integer_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:model_repository/model_repository.dart';
import 'package:sealed_currencies/sealed_currencies.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

class StartingFeeEditingPage extends StatelessWidget {
  const StartingFeeEditingPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (_) => StartingFeeEditingPage());
  }

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ModelSelectionCubit<Competition>(
            store: RepositoryProvider.of(context),
          ),
        ),
        BlocProvider(
          create: CompetitionListCubit.fromContext,
        ),
        BlocProvider(
          create: CompetitionSortingCubit.withDefaultComparators,
        ),
        BlocProvider(
          create: (context) => StartingFeeCurrencyCubit(
            tournamentStore: RepositoryProvider.of(context),
            l10n: l10n,
          ),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.configureStartingFees)),
        body: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 1000,
            child: const _StartingFeeList(),
          ),
        ),
      ),
    );
  }
}

class _StartingFeeList extends StatelessWidget {
  const _StartingFeeList();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CompetitionListCubit, CompetitionListState>(
      listenWhen: (previous, current) =>
          previous.displayCompetitionList != current.displayCompetitionList,
      listener: (context, state) {
        var selectionCubit = context.read<ModelSelectionCubit<Competition>>();
        selectionCubit.displayModelsChanged(state.displayCompetitionList);
      },
      builder: (context, state) {
        bool useAgeGroups =
            state.getCollection<TournamentEvent>().first.useAgeGroups;
        bool usePlayingLevels =
            state.getCollection<TournamentEvent>().first.usePlayingLevels;
        return Column(
          children: [
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _MassDiscountButton(),
                const SizedBox(width: 16),
                _CurrencySettingsButton(),
              ],
            ),
            const SizedBox(height: 14),
            _BulkSelectionButtons(),
            const SizedBox(height: 10),
            const CompetitionSelectionOptions(
              optionButtons: _CompetitionSelectionOptionButtons(),
            ),
            const SizedBox(height: 15),
            _StartingFeeListHeader(
              useAgeGroups: useAgeGroups,
              usePlayingLevels: usePlayingLevels,
            ),
            Expanded(
              child: _StartingFeeListBody(
                useAgeGroups: useAgeGroups,
                usePlayingLevels: usePlayingLevels,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Two buttons for selecting all singles or all doubles at once
class _BulkSelectionButtons extends StatelessWidget {
  const _BulkSelectionButtons();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () => selectByTeamsize(context, 1),
          icon: Icon(Icons.person),
          label: Text(l10n.selectAllSingles),
        ),
        const SizedBox(width: 16),
        TextButton.icon(
          onPressed: () => selectByTeamsize(context, 2),
          icon: Icon(Icons.group),
          label: Text(l10n.selectAllDoubles),
        ),
      ],
    );
  }

  void selectByTeamsize(BuildContext context, int size) {
    final ModelSelectionCubit<Competition> cubit =
        RepositoryProvider.of(context);
    final ModelSelectionState<Competition> state = cubit.state;

    List<Competition> selectedCompetitions = state.displayModels
        .where((competition) => competition.teamSize == size)
        .toList();

    cubit.multipleModelsToggled(selectedCompetitions);
  }
}

class _StartingFeeListHeader extends StatelessWidget {
  const _StartingFeeListHeader({
    required this.useAgeGroups,
    required this.usePlayingLevels,
  });

  final bool useAgeGroups;
  final bool usePlayingLevels;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return BlocBuilder<ModelSelectionCubit<Competition>,
        ModelSelectionState<Competition>>(
      buildWhen: (previous, current) =>
          previous.selectionTristate != current.selectionTristate,
      builder: (context, state) {
        var selectionCubit = context.read<ModelSelectionCubit<Competition>>();
        return DefaultTextStyle(
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontWeight: FontWeight.bold),
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
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const SizedBox(width: 15),
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: state.selectionTristate,
                      onChanged: (_) => selectionCubit.allModelsToggled(),
                      tristate: true,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Row(
                      children: [
                        if (useAgeGroups)
                          SortableCompetitionColumnHeader<
                              CompetitionComparator<AgeGroup>>(
                            width: 200,
                            title: l10n.ageGroup(1),
                          ),
                        if (usePlayingLevels)
                          SortableCompetitionColumnHeader<
                              CompetitionComparator<PlayingLevel>>(
                            width: 200,
                            title: l10n.playingLevel(1),
                          ),
                        SortableCompetitionColumnHeader<
                            CompetitionComparator<CompetitionDiscipline>>(
                          width: 150,
                          title: l10n.competition(1),
                        ),
                        Text(l10n.startingFeePerPlayer),
                        const SizedBox(width: 15),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StartingFeeListBody extends StatelessWidget {
  const _StartingFeeListBody({
    required this.useAgeGroups,
    required this.usePlayingLevels,
  });

  final bool useAgeGroups;
  final bool usePlayingLevels;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompetitionListCubit, CompetitionListState>(
      builder: (context, state) {
        return ListView(
          children: [
            for (final competition in state.displayCompetitionList) ...[
              _StartingFeeListItem(
                competition: competition,
                useAgeGroups: useAgeGroups,
                usePlayingLevels: usePlayingLevels,
              ),
              if (competition != state.displayCompetitionList.last)
                Divider(
                  height: 1,
                  thickness: 1,
                ),
            ]
          ],
        );
      },
    );
  }
}

class _StartingFeeListItem extends StatelessWidget {
  const _StartingFeeListItem({
    required this.competition,
    required this.useAgeGroups,
    required this.usePlayingLevels,
  });

  final Competition competition;
  final bool useAgeGroups;
  final bool usePlayingLevels;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var selectionCubit = context.read<ModelSelectionCubit<Competition>>();

    return BlocBuilder<ModelSelectionCubit<Competition>,
        ModelSelectionState<Competition>>(
      buildWhen: (previous, current) =>
          previous.selectedModels != current.selectedModels,
      builder: (context, state) {
        return CheckboxListTile(
          contentPadding: const EdgeInsetsDirectional.only(start: 16),
          controlAffinity: ListTileControlAffinity.leading,
          value: state.selectedModels.contains(competition),
          onChanged: (_) => selectionCubit.modelToggled(competition),
          title: DefaultTextStyle.merge(
            style: const TextStyle(fontSize: 14),
            child: Row(
              children: [
                if (useAgeGroups)
                  SizedBox(
                    width: 200,
                    child: Text(
                      competition.ageGroup != null
                          ? display_strings.ageGroup(
                              l10n, competition.ageGroup!)
                          : '',
                      overflow: TextOverflow.clip,
                      softWrap: false,
                    ),
                  ),
                if (usePlayingLevels)
                  SizedBox(
                    width: 200,
                    child: Text(
                      competition.playingLevel?.name ?? '',
                      overflow: TextOverflow.clip,
                      softWrap: false,
                    ),
                  ),
                SizedBox(
                  width: 150,
                  child: Text(
                    display_strings.competitionCategory(
                      l10n,
                      competition,
                    ),
                  ),
                ),
                _CompetitionFeeDisplay(
                  key: ValueKey('CompetitionFeeDisplay ${competition.id}'),
                  competition: competition,
                ),
                const SizedBox(width: 15),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CompetitionFeeDisplay extends StatelessWidget {
  const _CompetitionFeeDisplay({
    super.key,
    required this.competition,
  });

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    final borderRadius = BorderRadius.circular(8);

    return Tooltip(
      message: l10n.editStartingFees,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: () {
          final StartingFeeCurrencyCubit cubit = BlocProvider.of(context);
          showDialog(
            context: context,
            useRootNavigator: false,
            builder: (_) => _StartingFeeInputDialog(
              competitions: [competition],
              currency: cubit.state.currency,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withAlpha(128),
            borderRadius: borderRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child:
                BlocBuilder<StartingFeeCurrencyCubit, StartingFeeCurrencyState>(
              builder: (context, state) {
                final currency = state.currency;
                String formattedAmount = formatCurrency(
                  competition.startingFee,
                  currency,
                );
                String symbol =
                    currency.disambiguateSymbol ?? currency.symbol ?? '\$';
                formattedAmount = '$symbol $formattedAmount';
                return Row(
                  children: [
                    const SizedBox(width: 6),
                    Text(
                      formattedAmount,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.edit, size: 21),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _MassDiscountButton extends StatelessWidget {
  const _MassDiscountButton();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    final StartingFeeCurrencyCubit currencyCubit = BlocProvider.of(context);

    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          useRootNavigator: false,
          builder: (context) {
            return _StartingFeeMassDiscountDialog(
              currency: currencyCubit.state.currency,
            );
          },
        );
      },
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          Colors.blue[200],
        ),
        foregroundColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.onSurface,
        ),
        textStyle: WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.normal),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 6.0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.percent,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              l10n.configureMassDiscounts,
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencySettingsButton extends StatefulWidget {
  const _CurrencySettingsButton();

  @override
  State<_CurrencySettingsButton> createState() =>
      _CurrencySettingsButtonState();
}

class _CurrencySettingsButtonState extends State<_CurrencySettingsButton> {
  bool _dialogOpen = false;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    final StartingFeeCurrencyCubit cubit = BlocProvider.of(context);

    return BlocConsumer<StartingFeeCurrencyCubit, StartingFeeCurrencyState>(
      listener: (context, state) {
        if (state.formStatus == FormzSubmissionStatus.success && _dialogOpen) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return ElevatedButton(
          onPressed: () async {
            _dialogOpen = true;
            await showDialog(
              context: context,
              useRootNavigator: false,
              builder: (_) => CurrencySelectionDialog(
                onSelected: cubit.feeCurrencyChanged,
              ),
            );
            _dialogOpen = false;
          },
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(
              Colors.blue[200],
            ),
            foregroundColor: WidgetStatePropertyAll(
              Theme.of(context).colorScheme.onSurface,
            ),
            textStyle: WidgetStatePropertyAll(
              TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 6.0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${l10n.currency}: ${state.currency.name}',
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.settings,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CompetitionSelectionOptionButtons extends StatelessWidget {
  const _CompetitionSelectionOptionButtons();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BlocBuilder<ModelSelectionCubit<Competition>,
        ModelSelectionState<Competition>>(
      builder: (context, selectionStater) {
        int numSelected = selectionStater.selectedModels.length;

        VoidCallback? onPressed;
        if (numSelected > 0) {
          onPressed = () {
            final StartingFeeCurrencyCubit cubit = BlocProvider.of(context);
            showDialog(
              context: context,
              useRootNavigator: false,
              builder: (_) => _StartingFeeInputDialog(
                competitions: selectionStater.selectedModels,
                currency: cubit.state.currency,
              ),
            );
          };
        }

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: numSelected == 0 ? 0.0 : 1.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: onPressed,
                child: Text(l10n.editStartingFees),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StartingFeeInputDialog extends StatelessWidget {
  const _StartingFeeInputDialog({
    required this.competitions,
    required this.currency,
  });

  final List<Competition> competitions;
  final FiatCurrency currency;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => StartingFeeEditingCubit(
        competitions: competitions,
        competitionStore: RepositoryProvider.of(context),
        startingFeeEndpoint: RepositoryProvider.of(context),
      ),
      child: BlocConsumer<StartingFeeEditingCubit, StartingFeeEditingState>(
        listener: (context, state) {
          final done = state.formStatus == FormzSubmissionStatus.success;
          final allCompetitionsDeleted = state.competitions.isEmpty;
          if (done || allCompetitionsDeleted) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final StartingFeeEditingCubit cubit = BlocProvider.of(context);

          return AlertDialog(
            title: Text(
              l10n.editStartingFeesOfCompetitions(state.competitions.length),
            ),
            content: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500),
              child: CurrencyInput(
                currency: currency,
                amount: state.amount,
                onChanged: cubit.feeAmountChanged,
                onSubmitted: cubit.startingFeeSubmitted,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.close),
              ),
              TextButton(
                onPressed: cubit.startingFeeSubmitted,
                child: Text(l10n.save),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StartingFeeMassDiscountDialog extends StatelessWidget {
  const _StartingFeeMassDiscountDialog({
    required this.currency,
  });

  final FiatCurrency currency;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => MassDiscountEditingCubit(
        discountStore: RepositoryProvider.of(context),
        tournamentStore: RepositoryProvider.of(context),
        massDiscountEndpoint: RepositoryProvider.of(context),
      ),
      child: BlocBuilder<MassDiscountEditingCubit, MassDiscountEditingState>(
        builder: (context, state) {
          final MassDiscountEditingCubit cubit = BlocProvider.of(context);

          VoidCallback? onSubmitted;
          final validRegistrations = state.minRegistrations > 1;
          final validAmount = state.discountAmount > 0;
          final validSubmissionStatus =
              state.formStatus != FormzSubmissionStatus.inProgress;
          if (validRegistrations && validAmount && validSubmissionStatus) {
            onSubmitted = cubit.discountSubmitted;
          }

          return AlertDialog(
            title: Row(
              children: [
                Text(l10n.massDiscount(2)),
                const SizedBox(width: 8),
                HelpTooltipIcon(helpText: l10n.massDiscountInfo),
              ],
            ),
            content: SizedBox(
              width: 580,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MassDiscountInput(
                    minRegistrations: state.minRegistrations,
                    amount: state.discountAmount,
                    onMinRegistrationsChanged: cubit.minRegistrationsChanged,
                    onAmountChanged: cubit.discountAmountChanged,
                    onSubmitted: onSubmitted,
                    currency: currency,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.currentDiscountLevels,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  _MassDiscountList(
                    massDiscounts: state.discountLevels,
                    currency: currency,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MassDiscountInput extends StatelessWidget {
  const _MassDiscountInput({
    required this.minRegistrations,
    required this.amount,
    this.onMinRegistrationsChanged,
    this.onAmountChanged,
    this.onSubmitted,
    required this.currency,
  });

  final int minRegistrations;
  final int amount;

  final ValueChanged<int>? onMinRegistrationsChanged;
  final ValueChanged<int>? onAmountChanged;
  final VoidCallback? onSubmitted;

  final FiatCurrency currency;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        border: BoxBorder.all(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 220,
                        child: Text('${l10n.minRegistrations}:'),
                      ),
                      IntegerStepper(
                        value: minRegistrations,
                        minValue: 2,
                        maxValue: 99,
                        onChanged: onMinRegistrationsChanged,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 220,
                        child: Text('${l10n.discount}:'),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 150,
                        child: CurrencyInput(
                          currency: currency,
                          amount: amount,
                          onChanged: onAmountChanged,
                          onSubmitted: onSubmitted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onSubmitted,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(l10n.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MassDiscountList extends StatelessWidget {
  const _MassDiscountList({
    required this.massDiscounts,
    required this.currency,
  });

  final List<StartingFeeMassDiscount> massDiscounts;
  final FiatCurrency currency;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    if (massDiscounts.isEmpty) {
      return Text(
        l10n.noMassDiscountConfigured,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(110),
        ),
      );
    }
    return Column(
      children: [
        _MassDiscountListHeader(),
        SizedBox(
          height: 210,
          child: ImplicitAnimatedList(
            elements: massDiscounts,
            duration: const Duration(milliseconds: 120),
            itemBuilder: (context, massDiscount, animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: Column(
                  children: [
                    _MassDiscountListEntry(
                      massDiscount: massDiscount,
                      currency: currency,
                    ),
                    if (massDiscount != massDiscounts.last)
                      Divider(
                        height: 1,
                        thickness: 1,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MassDiscountListHeader extends StatelessWidget {
  const _MassDiscountListHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTextStyle.merge(
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 210,
            child: Text(l10n.numberOfRegistrations),
          ),
          SizedBox(
            width: 180,
            child: Text(l10n.discount),
          ),
        ],
      ),
    );
  }
}

class _MassDiscountListEntry extends StatelessWidget {
  const _MassDiscountListEntry({
    required this.massDiscount,
    required this.currency,
  });

  final StartingFeeMassDiscount massDiscount;
  final FiatCurrency currency;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    final MassDiscountEditingCubit cubit = BlocProvider.of(context);
    final String formattedAmount = formatCurrency(
      massDiscount.discountAmount,
      currency,
    );
    String symbol = currency.disambiguateSymbol ?? currency.symbol ?? '\$';

    return Row(
      children: [
        SizedBox(
          width: 210,
          child: Text('${massDiscount.minRegistrations}+'),
        ),
        SizedBox(
          width: 180,
          child: Text('$symbol $formattedAmount'),
        ),
        Spacer(),
        Tooltip(
          message: l10n.deleteSubject(l10n.discount),
          waitDuration: const Duration(milliseconds: 600),
          triggerMode: TooltipTriggerMode.manual,
          child: IconButton(
            onPressed: () => cubit.discountRemoved(massDiscount),
            icon: Icon(Icons.close),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}
