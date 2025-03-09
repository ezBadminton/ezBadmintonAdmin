class CallOutScriptState {
  CallOutScriptState({
    this.scriptPage = 0,
  });

  final int scriptPage;

  CallOutScriptState copyWith({
    int? scriptPage,
  }) {
    return CallOutScriptState(
      scriptPage: scriptPage ?? this.scriptPage,
    );
  }
}
