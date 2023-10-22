class TabNavigationState {
  TabNavigationState({
    this.selectedIndex = 0,
    this.tabChangeReason,
    this.fromIndex,
  });
  final int selectedIndex;
  final Object? tabChangeReason;
  final int? fromIndex;

  TabNavigationState copyWith({
    required int selectedIndex,
    Object? tabChangeReason,
    int? fromIndex,
  }) =>
      TabNavigationState(
        selectedIndex: selectedIndex,
        tabChangeReason: tabChangeReason,
        fromIndex: fromIndex,
      );
}
