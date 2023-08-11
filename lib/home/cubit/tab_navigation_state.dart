class TabNavigationState {
  TabNavigationState({
    this.selectedIndex = 0,
    this.tabChangeReason,
  });
  final int selectedIndex;
  final Object? tabChangeReason;

  TabNavigationState copyWith({
    required int selectedIndex,
    Object? tabChangeReason,
  }) =>
      TabNavigationState(
        selectedIndex: selectedIndex,
        tabChangeReason: tabChangeReason,
      );
}
