import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_consumer_cubit.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_consumer_state.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/predicate_producer.dart';
import 'package:ez_badminton_admin_app/widgets/popover_menu/popover_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

class FilterCheckbox<C extends PredicateConsumerCubit<S>,
    S extends PredicateConsumerState, T> extends StatelessWidget {
  const FilterCheckbox({
    super.key,
    required this.backgroundContext,
    required this.checkboxValue,
    required this.predicateProducer,
    required this.toggledValuesGetter,
    required this.onToggle,
    required this.label,
  });

  final BuildContext backgroundContext;
  final T checkboxValue;
  final PredicateProducer predicateProducer;
  final List<T> Function() toggledValuesGetter;
  final Function(T) onToggle;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BlocBuilder<C, S>(
          bloc: backgroundContext.read<C>(),
          buildWhen: (_, current) =>
              predicateProducer.producesDomain(current.filterPredicate?.domain),
          builder: (_, __) {
            return Checkbox(
              value: toggledValuesGetter().contains(checkboxValue),
              onChanged: (value) {
                onToggle(checkboxValue);
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
