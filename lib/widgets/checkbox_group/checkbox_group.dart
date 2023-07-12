import 'package:ez_badminton_admin_app/widgets/checkbox_group/cubit/checkbox_group_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef CheckboxGroupBuilder<T extends Object> = Widget Function(
  BuildContext context,
  List<T> elements,
  void Function(T element) onToggle,
  bool Function(T element) valueGetter,
);

class CheckboxGroup<T extends Object> extends StatelessWidget {
  /// A CheckboxGroup managing its state with a cubit.
  ///
  /// See also
  /// * [RawCheckboxGroup] which this is built upon.
  const CheckboxGroup({
    super.key,
    required this.elements,
    required this.title,
    required this.groupBuilder,
    this.initialEnabledElements = const [],
    this.onChange,
  });

  final List<T> elements;
  final Widget title;
  final CheckboxGroupBuilder<T> groupBuilder;

  final List<T> initialEnabledElements;

  final void Function(List<T> enabledElements)? onChange;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CheckboxGroupCubit(
        elements: elements,
        intialEnabledElements: initialEnabledElements,
      ),
      child: Builder(
        builder: (context) {
          return BlocConsumer<CheckboxGroupCubit<T>, CheckboxGroupState<T>>(
            listener: (context, state) {
              if (onChange != null) {
                onChange!(state.enabledElements);
              }
            },
            buildWhen: (previous, current) =>
                previous.allElements != current.allElements,
            builder: (context, state) {
              var cubit = context.read<CheckboxGroupCubit<T>>();
              return RawCheckboxGroup<T>(
                elements: state.allElements,
                title: title,
                groupBuilder: groupBuilder,
                onToggle: cubit.elementToggled,
                valueGetter: cubit.isElementEnabled,
                onGroupToggle: cubit.groupToggled,
                groupValueGetter: cubit.isGroupEnabled,
              );
            },
          );
        },
      ),
    );
  }
}

class RawCheckboxGroup<T extends Object> extends StatelessWidget {
  /// A group of checkboxes with a super-checkbox that can
  /// toggle all in the group.
  ///
  /// This raw widget does not maintain a state and only builds the group by
  /// using the list of [elements] given to the [groupBuilder].
  /// The [groupBuilder] accesses and modifies the state of each element using
  /// the given [onToggle] and [valueGetter] functions.
  /// The super-checkbox's state is controlled by [onGroupToggle] and read
  /// as a tristate with [groupValueGetter].
  const RawCheckboxGroup({
    super.key,
    required this.elements,
    required this.title,
    required this.groupBuilder,
    required this.onToggle,
    required this.valueGetter,
    required this.onGroupToggle,
    required this.groupValueGetter,
  });

  final List<T> elements;
  final Widget title;
  final CheckboxGroupBuilder<T> groupBuilder;
  final void Function(T element) onToggle;
  final bool Function(T element) valueGetter;
  final VoidCallback onGroupToggle;
  final bool? Function() groupValueGetter;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(.25),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              children: [
                const SizedBox(width: 15),
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: groupValueGetter(),
                    onChanged: (_) => onGroupToggle(),
                    tristate: true,
                  ),
                ),
                const SizedBox(width: 10),
                title,
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            indent: 12,
            endIndent: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(.25),
          ),
          groupBuilder(
            context,
            elements,
            onToggle,
            valueGetter,
          ),
        ],
      ),
    );
  }
}
