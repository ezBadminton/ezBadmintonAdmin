import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/widgets/custom_input_fields/clearable_dropdown_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GenderCategoryInput extends StatelessWidget {
  const GenderCategoryInput({
    super.key,
    required this.onChanged,
    required this.currentValue,
    required this.genderCategoryOptions,
    this.showDeleteButton = true,
  });

  final void Function(GenderCategory? value) onChanged;
  final GenderCategory? currentValue;
  final List<GenderCategory> genderCategoryOptions;
  final bool showDeleteButton;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return ClearableDropdownButton<GenderCategory>(
      value: currentValue,
      onChanged: onChanged,
      label: Text(l10n.gender),
      items: genderCategoryOptions
          .map((category) => DropdownMenuItem(
                value: category,
                child: Text(l10n.genderCategory(category.name)),
              ))
          .toList(),
    );
  }
}
