import 'package:flutter/material.dart';

class PositionedResizer extends StatefulWidget {
  final double defaultWidth;

  final double minWidth;

  final double maxWidth;

  final void Function(double width) onChange;

  final Color color;

  final double thickness;

  const PositionedResizer({
    required this.minWidth,
    required this.maxWidth,
    required this.defaultWidth,
    required this.onChange,
    this.color = const Color.fromRGBO(125, 125, 125, 1.0),
    this.thickness = 2,
    super.key,
  });

  @override
  State<PositionedResizer> createState() => _PositionedResizerState();
}

class _PositionedResizerState extends State<PositionedResizer> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: 0,
      bottom: 0,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeLeftRight,
        child: GestureDetector(
          onHorizontalDragUpdate: (e) {
            _delta += e.delta.dx;
            _updateWidth(_delta);
          },
          onHorizontalDragStart: (e) {
            _delta = 0;
            _startingLeft = left;
          },
          child: Container(
            width: widget.thickness,
            height: double.infinity,
            decoration: BoxDecoration(
              /*color: Colors.blue,
              gradient: LinearGradient(
                colors: [
                  Colors.black38,
                  Colors.white,
                  color,
                  color,
                  color,
                  Colors.white,
                  Colors.black38,
                ],
                stops: [0, 0.1, 0.1, 0.5, 0.9, 0.9, 1],
              ),*/  
            ),
          ),
        ),
      ),
    );
  }

  static Color color = Color.fromRGBO(125, 125, 125, 1.0);

  void _updateWidth(double delta) {
    setState(() {
      left = _startingLeft + delta;
      if (left < widget.minWidth) {
        left = widget.minWidth;
      } else if (left > widget.maxWidth) {
        left = widget.maxWidth;
      }
    });
    widget.onChange(left);
  }

  double _delta = 0;
  late double _startingLeft = left;

  late double left = widget.defaultWidth;
}
