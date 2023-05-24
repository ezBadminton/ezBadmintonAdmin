import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/widgets/custom_input_fields/clearable_dropdown_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AgeGroupInput extends StatelessWidget {
  const AgeGroupInput({
    super.key,
    required this.onChanged,
    required this.currentValue,
    required this.ageGroupOptions,
    this.showDeleteButton = true,
  });

  final void Function(AgeGroup? value) onChanged;
  final AgeGroup? currentValue;
  final List<AgeGroup> ageGroupOptions;
  final bool showDeleteButton;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return ClearableDropdownButton<AgeGroup>(
      value: currentValue,
      onChanged: onChanged,
      label: Text(l10n.ageGroup),
      items: ageGroupOptions
          .map((group) => DropdownMenuItem(
                value: group,
                child: Text(
                  '${l10n.ageGroupAbbreviated(group.type.name)}${group.age}',
                ),
              ))
          .toList(),
    );
  }
}
