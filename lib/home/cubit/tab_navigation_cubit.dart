import 'package:bloc/bloc.dart';

class TabNavigationCubit extends Cubit<int> {
  TabNavigationCubit() : super(0);

  void tabChanged(int selectedIndex) {
    emit(selectedIndex);
  }
}
