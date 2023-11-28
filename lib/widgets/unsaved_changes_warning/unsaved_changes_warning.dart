import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// When the user tries to leave the current scope and the [formState] has
/// unsaved changes, this widget shows a warning
class UnsavedChangesWarning extends StatefulWidget {
  const UnsavedChangesWarning({
    super.key,
    required this.formState,
    required this.child,
  });

  final FormzMixin formState;

  final Widget child;

  @override
  State<UnsavedChangesWarning> createState() => _UnsavedChangesWarningState();
}

class _UnsavedChangesWarningState extends State<UnsavedChangesWarning> {
  late bool _userDismissedChanges;

  @override
  void initState() {
    super.initState();
    _userDismissedChanges = false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.formState.isPure || _userDismissedChanges,
      onPopInvoked: (bool didPop) {
        if (!didPop) {
          _showUnsavedChangesDialog(context);
        }
      },
      child: widget.child,
    );
  }

  void _showUnsavedChangesDialog(BuildContext context) async {
    var l10n = AppLocalizations.of(context)!;
    NavigatorState navigatorState = Navigator.of(context);

    bool? dismissChanges = await showDialog<bool>(
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

    setState(() {
      _userDismissedChanges = dismissChanges!;
    });

    if (_userDismissedChanges) {
      navigatorState.pop();
    }
  }
}
