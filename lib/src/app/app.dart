import 'package:flutter/material.dart';
import 'package:turtle/src/app/positioned_resizer.dart';
import 'package:turtle/src/editor/editor.dart';
import 'package:turtle/src/model/model.dart';
import 'package:turtle/src/model/program.dart';
import 'package:turtle/src/properties_editor/properties_editor.dart';

class App extends StatefulWidget {
  final Program program;

  const App({required this.program, super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    final theme = ThemeInjector.of(context);
    return Container(
      decoration: BoxDecoration(color: theme.appBackground),
      child: Stack(
        children: [
          // TODO preview
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: _split2,
            child: ProgramEditor(
              program: program,
              selectedNodes: selectedNodes,
              onSelectionChange: _onSelectionChange,
            ),
          ),
          Positioned(
            left: _split2,
            top: 0,
            bottom: 0,
            right: 0,
            child: PropertiesEditor(program: program, nodes: selectedNodes),
          ),
          PositionedResizer(
            defaultWidth: _split2,
            minWidth: 200,
            maxWidth: 800,
            color: Colors.transparent,
            onChange: (v) {
              setState(() {
                _split2 = v;
              });
            },
          ),
        ],
      ),
    );
  }

  void _onSelectionChange(Set<Node> nodes) {
    setState(() {
      selectedNodes = nodes;
    });
  }

  double _split2 = 800;

  Program get program => widget.program;

  Set<Node> selectedNodes = {};
}

class MyTheme {
  final Color appBackground;
  final Color headerBackground;
  final BorderRadius headerBorderRadius;
  final Color headerTitleColor;
  final TextStyle headerTitleStyle;
  final Color panelBackground;
  final Border panelBorder;
  final BorderRadius panelBorderRadius;

  MyTheme({
    required this.appBackground,
    required this.headerBackground,
    required this.headerBorderRadius,
    required this.headerTitleStyle,
    required this.headerTitleColor,
    required this.panelBackground,
    required this.panelBorder,
    required this.panelBorderRadius,
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
  );
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
