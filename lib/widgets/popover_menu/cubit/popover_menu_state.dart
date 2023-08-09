part of 'popover_menu_cubit.dart';

@immutable
class PopoverMenuState {
  PopoverMenuState({
    this.menu = const [],
    required this.menuContent,
  }) : isMenuOpen = menu.isNotEmpty;

  final List<OverlayEntry> menu;
  final Widget menuContent;
  final bool isMenuOpen;

  PopoverMenuState copyWith({
    List<OverlayEntry>? menu,
    Widget? menuContent,
  }) {
    return PopoverMenuState(
      menu: menu ?? this.menu,
      menuContent: menuContent ?? this.menuContent,
    );
  }
}
