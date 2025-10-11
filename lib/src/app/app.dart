import 'package:flutter/material.dart';
import 'package:turtle/src/app/positioned_resizer.dart';
import 'package:turtle/src/app/theme.dart';
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
