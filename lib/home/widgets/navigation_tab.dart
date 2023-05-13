import 'package:flutter/material.dart';

class NavigationTab {
  const NavigationTab({
    required this.index,
    required this.label,
    required this.root,
    required this.unselectedIcon,
    required this.selectedIcon,
  });

  final int index;
  final String label;
  final Widget root;
  final IconData unselectedIcon;
  final IconData selectedIcon;
}

class NavigationTabView extends StatelessWidget {
  const NavigationTabView({
    super.key,
    required this.tab,
    required this.navigatorKey,
  });

  final NavigationTab tab;
  final Key navigatorKey;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (_) => tab.root,
      ),
    );
  }
}
