import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/widgets/implicit_animated_list/implicit_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;
import 'package:ez_badminton_admin_app/competition_management/age_group_editing/cubit/age_group_editing_cubit.dart';

class AgeGroupEditingPopup extends StatelessWidget {
  const AgeGroupEditingPopup({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => AgeGroupEditingCubit(
        ageGroupRepository: context.read<CollectionRepository<AgeGroup>>(),
        competitionRepository:
            context.read<CollectionRepository<Competition>>(),
      ),
      child: Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.ageGroup(2),
                  style: const TextStyle(fontSize: 22),
                ),
                const Divider(height: 25, indent: 20, endIndent: 20),
                _AgeGroupForm(),
                const Divider(height: 25, indent: 20, endIndent: 20),
                const _AgeGroupList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AgeGroupList extends StatelessWidget {
  const _AgeGroupList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AgeGroupEditingCubit, AgeGroupEditingState>(
      buildWhen: (previous, current) =>
          previous.isDeletable != current.isDeletable ||
          previous.getCollection<AgeGroup>() !=
              current.getCollection<AgeGroup>(),
      builder: (context, state) {
        List<AgeGroup> ageGroups =
            state.collections[AgeGroup] as List<AgeGroup>? ?? [];
        return SizedBox(
          height: 300,
          child: ImplicitAnimatedList<AgeGroup>(
            elements: ageGroups,
            duration: const Duration(milliseconds: 120),
            itemBuilder: (context, ageGroup, animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: _AgeGroupListItem(
                  ageGroup: ageGroup,
                  index: ageGroups.indexOf(ageGroup),
                  deletable: state.isDeletable,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _AgeGroupListItem extends StatelessWidget {
  const _AgeGroupListItem({
    required this.ageGroup,
    required this.index,
    this.deletable = true,
  });

  final AgeGroup ageGroup;
  final int index;
  final bool deletable;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<AgeGroupEditingCubit>();
    return Column(
      children: [
        if (index != 0)
          const Divider(
            height: 1,
            thickness: 1,
          ),
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 10),
          child: Row(
            children: [
              Text(
                display_strings.ageGroup(l10n, ageGroup),
                style: const TextStyle(fontSize: 16),
              ),
              const Expanded(child: SizedBox()),
              Tooltip(
                message: l10n.deleteSubject(l10n.ageGroup(1)),
                waitDuration: const Duration(milliseconds: 600),
                triggerMode: TooltipTriggerMode.manual,
                child: IconButton(
                  onPressed: () {
                    if (deletable) {
                      cubit.ageGroupRemoved(ageGroup);
                    }
                  },
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AgeGroupForm extends StatelessWidget {
  _AgeGroupForm();

  final FocusNode _focus = FocusNode();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<AgeGroupEditingCubit>();
    return BlocConsumer<AgeGroupEditingCubit, AgeGroupEditingState>(
      listenWhen: (previous, current) =>
          previous.collections.containsKey(AgeGroup) &&
          previous.getCollection<AgeGroup>().length <
              current.getCollection<AgeGroup>().length,
      listener: (context, state) {
        _controller.text = '';
        cubit.ageChanged('');
        _focus.requestFocus();
      },
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AgeGroupTypeRadio(
                  ageGroupType: AgeGroupType.over,
                  selectedAgeGroupType: state.ageGroupType.value,
                  onChanged: (AgeGroupType? ageGroupType) {
                    cubit.ageGroupTypeChanged(ageGroupType);
                    _focus.requestFocus();
                  },
                  label: l10n.overAge,
                ),
                _AgeGroupTypeRadio(
                  ageGroupType: AgeGroupType.under,
                  selectedAgeGroupType: state.ageGroupType.value,
                  onChanged: (AgeGroupType? ageGroupType) {
                    cubit.ageGroupTypeChanged(ageGroupType);
                    _focus.requestFocus();
                  },
                  label: l10n.underAge,
                ),
              ],
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 50,
              child: TextField(
                onChanged: (String value) {
                  cubit.ageChanged(value);
                },
                inputFormatters: [
                  LengthLimitingTextInputFormatter(2),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                controller: _controller,
                focusNode: _focus,
                onSubmitted: (_) {
                  if (state.isSubmittable) {
                    cubit.ageGroupSubmitted();
                  }
                },
                decoration: InputDecoration(
                  hintText: l10n.age,
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.background.withOpacity(.5),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  enabledBorder:
                      const OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder:
                      const OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: state.isSubmittable ? cubit.ageGroupSubmitted : null,
              child: Text(l10n.add),
            ),
          ],
        );
      },
    );
  }
}

class _AgeGroupTypeRadio extends StatelessWidget {
  const _AgeGroupTypeRadio({
    required this.ageGroupType,
    required this.selectedAgeGroupType,
    required this.onChanged,
    required this.label,
  });

  final AgeGroupType ageGroupType;
  final AgeGroupType? selectedAgeGroupType;
  final void Function(AgeGroupType? ageGroupType) onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(ageGroupType);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<AgeGroupType>(
            value: ageGroupType,
            groupValue: selectedAgeGroupType,
            onChanged: (_) {
              onChanged(ageGroupType);
            },
          ),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
