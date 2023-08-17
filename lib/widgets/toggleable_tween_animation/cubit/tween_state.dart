class TweenState {
  TweenState({
    this.targetValue = 0.0,
    this.currentValue = 0.0,
  });

  final double targetValue;
  final double currentValue;

  TweenState copyWith({
    double? targetValue,
    double? currentValue,
  }) {
    return TweenState(
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
    );
  }
}
