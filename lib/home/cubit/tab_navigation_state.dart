class TabNavigationState {
  TabNavigationState({
    this.selectedIndex = 0,
    this.previousIndex = 0,
  });
  final int selectedIndex;
  final int previousIndex;

  TabNavigationState copyWith({required int selectedIndex}) =>
      TabNavigationState(
        selectedIndex: selectedIndex,
        previousIndex: this.selectedIndex,
      );
}
