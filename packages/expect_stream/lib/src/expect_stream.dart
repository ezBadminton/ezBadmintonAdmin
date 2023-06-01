import 'package:flutter_test/flutter_test.dart';

/// Test the contents of a single subscriber [stream] against a list of
/// [matchers]
///
/// Example:
///
/// When testing a single subscriber stream:
/// ```dart
/// exampleStreamController.add(exampleEvent);
/// await expectStream(exampleStream, [exampleEvent]);
/// ```
Future<void> expectStream<T>(
  Stream<T> stream,
  List<dynamic> matchers, {
  int skip = 0,
}) async {
  final streamedData = <T>[];
  final subscription = stream.skip(skip).listen(streamedData.add);
  await Future.delayed(Duration.zero);
  expect(streamedData, wrapMatcher(matchers));

  subscription.cancel();
}

/// Test the contents of a broadcast [stream] against a list of [matchers]
///
/// Example:
///
/// When testing a broadcast stream:
/// ```dart
/// var expectation = expectBroadcastStream(exampleStream, [exampleEvent]);
/// exampleStreamController.add(exampleEvent);
/// exampleStreamController.close();
/// await expectation;
/// ```
Future<void> expectBroadcastStream<T>(
  Stream<T> stream,
  List<dynamic> matchers, {
  int skip = 0,
}) async {
  final streamedData = <T>[];
  await stream.skip(skip).forEach(streamedData.add);
  expect(streamedData, wrapMatcher(matchers));
}
