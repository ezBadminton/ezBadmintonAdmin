import 'package:ez_badminton_admin_app/widgets/checkbox_group/cubit/checkbox_group_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef CheckboxGroupBuilder<T extends Object> = Widget Function(
  BuildContext context,
  List<T> elements,
  void Function(T element) onToggle,
  bool Function(T element) isEnabled,
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
  });

  final List<T> elements;
  final Widget title;
  final CheckboxGroupBuilder<T> groupBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CheckboxGroupCubit(elements: elements),
      child: Builder(
        builder: (context) {
          return BlocBuilder<CheckboxGroupCubit<T>, CheckboxGroupState<T>>(
            builder: (context, state) {
              var cubit = context.read<CheckboxGroupCubit<T>>();
              return RawCheckboxGroup<T>(
                elements: elements,
                title: title,
                groupBuilder: groupBuilder,
                onToggle: cubit.elementToggled,
                isEnabled: cubit.isElementEnabled,
                onGroupToggle: cubit.groupToggled,
                isGroupEnabled: cubit.isGroupEnabled,
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
  /// the given [onToggle] and [isEnabled] functions.
  /// The super-checkbox's state is controlled by [onGroupToggle] and read
  /// as a tristate with [isGroupEnabled].
  const RawCheckboxGroup({
    super.key,
    required this.elements,
    required this.title,
    required this.groupBuilder,
    required this.onToggle,
    required this.isEnabled,
    required this.onGroupToggle,
    required this.isGroupEnabled,
  });

  final List<T> elements;
  final Widget title;
  final CheckboxGroupBuilder<T> groupBuilder;
  final void Function(T element) onToggle;
  final bool Function(T element) isEnabled;
  final VoidCallback onGroupToggle;
  final bool? Function() isGroupEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.onSurface),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: isGroupEnabled(),
                      onChanged: (_) => onGroupToggle(),
                      tristate: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  title,
                ],
              ),
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          groupBuilder(
            context,
            elements,
            onToggle,
            isEnabled,
          ),
        ],
      ),
    );
  }
}
