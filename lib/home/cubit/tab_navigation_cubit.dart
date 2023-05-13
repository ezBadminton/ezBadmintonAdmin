import 'package:bloc/bloc.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_state.dart';
import 'package:ez_badminton_admin_app/home/widgets/navigation_tab.dart';

class TabNavigationCubit extends Cubit<TabNavigationState> {
  TabNavigationCubit(List<NavigationTab> navigationTabs)
      : super(TabNavigationState());

  void tabChanged(int selectedIndex) {
    emit(state.copyWith(selectedIndex: selectedIndex));
  }
}
