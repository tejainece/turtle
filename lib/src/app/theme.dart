import 'package:flutter/material.dart';

class MyTheme {
  final Color appBackground;
  final Color headerBackground;
  final BorderRadius headerBorderRadius;
  final Color headerTitleColor;
  final TextStyle headerTitleStyle;
  final Color panelBackground;
  final Border panelBorder;
  final BorderRadius panelBorderRadius;
  final NodeTheme node;

  MyTheme({
    required this.appBackground,
    required this.headerBackground,
    required this.headerBorderRadius,
    required this.headerTitleStyle,
    required this.headerTitleColor,
    required this.panelBackground,
    required this.panelBorder,
    required this.panelBorderRadius,
    required this.node,
  });

  static final dark = MyTheme(
    appBackground: Color.fromARGB(255, 47, 47, 47),
    headerBackground: Color.fromARGB(255, 0, 4, 77),
    headerBorderRadius: BorderRadius.only(
      topLeft: Radius.circular(7),
      topRight: Radius.circular(7),
    ),
    headerTitleColor: Colors.white,
    headerTitleStyle: TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    panelBackground: Color.fromARGB(255, 47, 47, 47),
    panelBorder: Border.all(
      color: const Color.fromARGB(255, 130, 130, 130),
      width: 1,
    ),
    panelBorderRadius: BorderRadius.circular(7),
    node: NodeTheme(
      background: const Color.fromARGB(255, 0, 27, 45),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color.fromARGB(255, 3, 38, 83), width: 2),
      selectedBorder: Border.all(color: Colors.green, width: 2),
      titleBackground: Color.fromRGBO(0, 0, 0, 0.4),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        overflow: TextOverflow.fade,
      ),
      socketSize: 10,
      socketSpacing: 5,
      socketVerticalMargin: 2,
      socketThickness: 2,
    ),
  );
}

class NodeTheme {
  final Color background;
  final BorderRadius borderRadius;
  final Border border;
  final Border selectedBorder;
  final Color titleBackground;
  final TextStyle titleTextStyle;
  final double socketSize;
  final double socketSpacing;
  final double socketVerticalMargin;
  final double socketThickness;

  const NodeTheme({
    required this.background,
    required this.border,
    required this.borderRadius,
    required this.selectedBorder,
    required this.titleBackground,
    required this.titleTextStyle,
    required this.socketSize,
    required this.socketSpacing,
    required this.socketVerticalMargin,
    required this.socketThickness,
  });
}

class ThemeInjector extends InheritedWidget {
  final MyTheme theme;

  const ThemeInjector({required this.theme, required super.child, super.key});

  static MyTheme of(BuildContext context) {
    final ThemeInjector? result = context
        .dependOnInheritedWidgetOfExactType<ThemeInjector>();
    assert(result != null, 'No ThemeInjector found in context');
    return result!.theme;
  }

  @override
  bool updateShouldNotify(ThemeInjector oldWidget) {
    return theme != oldWidget.theme;
  }
}
