import 'package:bloc/bloc.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_state.dart';

class TabNavigationCubit extends Cubit<TabNavigationState> {
  TabNavigationCubit() : super(TabNavigationState());

  /// Changes the active tab
  ///
  /// If the tab was changed and something should happen on the
  /// tab that was changed to, then a [reason] object can be supplied that a
  /// widget in the new tab can read.
  void tabChanged(
    int selectedIndex, {
    Object? reason,
  }) {
    emit(state.copyWith(
      selectedIndex: selectedIndex,
      tabChangeReason: reason,
    ));
  }
}
