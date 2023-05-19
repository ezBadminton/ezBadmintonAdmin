import 'package:flutter/material.dart';

enum LoadingStatus { loading, failed, done }

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    super.key,
    required this.loadingStatusGetter,
    this.errorMessage = 'Could not load!',
    this.retryFunction,
    this.retryButtonLabel = 'Retry',
    this.loadingIndicator = const CircularProgressIndicator(),
    required this.child,
  });

  final LoadingStatus Function() loadingStatusGetter;
  final String errorMessage;
  final void Function()? retryFunction;
  final String retryButtonLabel;
  final Widget loadingIndicator;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    switch (loadingStatusGetter()) {
      case LoadingStatus.loading:
        return loadingIndicator;
      case LoadingStatus.failed:
        var column = <Widget>[Text(errorMessage)];
        if (retryFunction != null) {
          column.add(
            ElevatedButton(
              onPressed: retryFunction,
              child: Text(retryButtonLabel),
            ),
          );
        }
        return Column(
          children: column,
        );
      case LoadingStatus.done:
        return child;
    }
  }
}
