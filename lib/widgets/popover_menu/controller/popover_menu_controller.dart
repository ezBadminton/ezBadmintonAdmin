import 'package:ez_badminton_admin_app/widgets/popover_menu/popover_menu.dart';
import 'package:flutter/foundation.dart';

/// An object for controlling the opening/closing of a [PopoverMenuButton].
///
/// The state of the controller does not reflect the open-state of the
/// [PopoverMenuButton]. If the button is already open and [openMenu] is called
/// on the controller, nothing happens.
class PopoverMenuController extends ChangeNotifier {
  PopoverMenuController();

  bool _isMenuOpen = false;
  bool get isMenuOpen => _isMenuOpen;

  void openMenu() {
    _isMenuOpen = true;
    super.notifyListeners();
  }

  void closeMenu() {
    _isMenuOpen = false;
    super.notifyListeners();
  }
}
