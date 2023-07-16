import 'package:flutter/material.dart';

/// A simple [AlertDialog] with 2 buttons for confirm/cancel
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    this.title,
    this.content,
    required this.confirmButtonLabel,
    required this.cancelButtonLabel,
  });

  final Widget? title;
  final Widget? content;

  final String confirmButtonLabel;
  final String cancelButtonLabel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      content: content,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmButtonLabel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelButtonLabel),
        ),
      ],
    );
  }
}
