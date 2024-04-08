/// Singleton class that holds information about wether the runtime environment
/// is testing
class TestEnvironment {
  static final TestEnvironment _instance = TestEnvironment._();

  TestEnvironment._();

  factory TestEnvironment() {
    return _instance;
  }

  bool isTest = false;
}
