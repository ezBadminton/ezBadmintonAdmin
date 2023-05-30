import 'package:flutter/material.dart';

enum LoadingStatus { loading, failed, done }

LoadingStatus loadingStatusConjunction(List<LoadingStatus> statusList) {
  if (statusList.contains(LoadingStatus.loading)) {
    return LoadingStatus.loading;
  } else if (statusList.contains(LoadingStatus.failed)) {
    return LoadingStatus.failed;
  }
  return LoadingStatus.done;
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    super.key,
    required this.loadingStatusGetter,
    this.errorMessage = 'Could not load!',
    this.onRetry,
    this.retryButtonLabel = 'Retry',
    this.loadingIndicator = const Center(child: CircularProgressIndicator()),
    required this.builder,
  });

  final LoadingStatus Function() loadingStatusGetter;
  final String errorMessage;
  final void Function()? onRetry;
  final String retryButtonLabel;
  final Widget loadingIndicator;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    switch (loadingStatusGetter()) {
      case LoadingStatus.loading:
        return loadingIndicator;
      case LoadingStatus.failed:
        var column = <Widget>[Text(errorMessage)];
        if (onRetry != null) {
          column.add(
            ElevatedButton(
              onPressed: onRetry,
              child: Text(retryButtonLabel),
            ),
          );
        }
        return Column(
          children: column,
        );
      case LoadingStatus.done:
        return builder(context);
    }
  }
}
