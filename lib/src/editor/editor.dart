import 'package:flutter/material.dart';
import 'package:turtle/src/processor/processor.dart';

class Editor extends StatefulWidget {
  const Editor({super.key});

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // TODO
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class Viewport {
  Size size;
  Offset center;
  Viewport({required this.size, required this.center});
}