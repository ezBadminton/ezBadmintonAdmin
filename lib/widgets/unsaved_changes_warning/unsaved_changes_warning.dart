import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// When the user tries to leave the current scope and the [formState] has
/// unsaved changes, this widget shows a warning
class UnsavedChangesWarning extends StatelessWidget {
  const UnsavedChangesWarning({
    super.key,
    required this.formState,
    required this.child,
  });

  final FormzMixin formState;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (formState.isDirty) {
          return _showUnsavedChangesDialog(context);
        } else {
          return true;
        }
      },
      child: child,
    );
  }

  Future<bool> _showUnsavedChangesDialog(BuildContext context) async {
    var l10n = AppLocalizations.of(context)!;
    var dismissChanges = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.unsavedChanges),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.dismissChanges),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
    dismissChanges ??= false;
    return dismissChanges;
  }
}
