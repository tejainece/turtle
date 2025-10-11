import 'package:flutter/material.dart';

class BoxResizer extends StatefulWidget {
  final Widget child;
  final void Function(ResizeDir dir, PointerDownEvent event) onResizeStart;
  const BoxResizer({
    required this.child,
    required this.onResizeStart,
    super.key,
  });

  @override
  State<BoxResizer> createState() => _BoxResizerState();
}

class _BoxResizerState extends State<BoxResizer> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 5,
          child: MouseRegion(
            opaque: true,
            hitTestBehavior: HitTestBehavior.deferToChild,
            cursor: SystemMouseCursors.resizeDown,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) {
                widget.onResizeStart(ResizeDir.bottom, event);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _showColor ? Colors.red : null,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 5,
          child: MouseRegion(
            opaque: true,
            hitTestBehavior: HitTestBehavior.deferToChild,
            cursor: SystemMouseCursors.resizeUp,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) {
                widget.onResizeStart(ResizeDir.top, event);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _showColor ? Colors.red : null,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: 5,
          child: MouseRegion(
            opaque: true,
            hitTestBehavior: HitTestBehavior.deferToChild,
            cursor: SystemMouseCursors.resizeLeft,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) {
                widget.onResizeStart(ResizeDir.left, event);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _showColor ? Colors.red : null,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: 5,
          child: MouseRegion(
            opaque: true,
            hitTestBehavior: HitTestBehavior.deferToChild,
            cursor: SystemMouseCursors.resizeRight,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) {
                widget.onResizeStart(ResizeDir.right, event);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _showColor ? Colors.red : null,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          width: 10,
          height: 5,
          child: MouseRegion(
            opaque: true,
            hitTestBehavior: HitTestBehavior.deferToChild,
            cursor: SystemMouseCursors.resizeUpLeft,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) {
                widget.onResizeStart(ResizeDir.topLeft, event);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _showColor ? Colors.green : null,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          width: 5,
          height: 10,
          child: MouseRegion(
            opaque: true,
            hitTestBehavior: HitTestBehavior.deferToChild,
            cursor: SystemMouseCursors.resizeUpLeft,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) {
                widget.onResizeStart(ResizeDir.topLeft, event);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _showColor ? Colors.green : null,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          width: 10,
          height: 5,
          child: MouseRegion(
            opaque: true,
            hitTestBehavior: HitTestBehavior.deferToChild,
            cursor: SystemMouseCursors.resizeUpRight,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) {
                widget.onResizeStart(ResizeDir.topRight, event);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _showColor ? Colors.green : null,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          width: 5,
          height: 10,
          child: MouseRegion(
            opaque: true,
            hitTestBehavior: HitTestBehavior.deferToChild,
            cursor: SystemMouseCursors.resizeUpRight,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) {
                widget.onResizeStart(ResizeDir.topRight, event);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _showColor ? Colors.green : null,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          width: 10,
          height: 5,
          child: MouseRegion(
            opaque: true,
            hitTestBehavior: HitTestBehavior.deferToChild,
            cursor: SystemMouseCursors.resizeDownLeft,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) {
                widget.onResizeStart(ResizeDir.bottomLeft, event);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _showColor ? Colors.green : null,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          width: 5,
          height: 10,
          child: MouseRegion(
            opaque: true,
            hitTestBehavior: HitTestBehavior.deferToChild,
            cursor: SystemMouseCursors.resizeDownLeft,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) {
                widget.onResizeStart(ResizeDir.bottomLeft, event);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _showColor ? Colors.green : null,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          width: 10,
          height: 5,
          child: MouseRegion(
            opaque: true,
            hitTestBehavior: HitTestBehavior.deferToChild,
            cursor: SystemMouseCursors.resizeDownRight,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) {
                widget.onResizeStart(ResizeDir.bottomRight, event);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _showColor ? Colors.green : null,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          width: 5,
          height: 10,
          child: MouseRegion(
            opaque: true,
            hitTestBehavior: HitTestBehavior.deferToChild,
            cursor: SystemMouseCursors.resizeDownRight,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) {
                widget.onResizeStart(ResizeDir.bottomRight, event);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _showColor ? Colors.green : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _showColor = false;
}

enum ResizeDir {
  left,
  right,
  top,
  bottom,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}
