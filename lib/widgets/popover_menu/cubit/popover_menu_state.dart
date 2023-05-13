part of 'popover_menu_cubit.dart';

@immutable
class PopoverMenuState {
  static const double initialOpacity = 0.0;
  static const double initialScale = 0.5;

  const PopoverMenuState({
    this.menu = const [],
    this.opacity = initialOpacity,
    this.scale = initialScale,
  });
  final List<OverlayEntry> menu;
  final double opacity;
  final double scale;

  PopoverMenuState copyWith({
    List<OverlayEntry>? menu,
    double? opacity,
    double? scale,
  }) {
    return PopoverMenuState(
      menu: menu ?? this.menu,
      opacity: opacity ?? this.opacity,
      scale: scale ?? this.scale,
    );
  }
}
