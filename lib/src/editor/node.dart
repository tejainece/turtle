import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:turtle/src/app/app.dart';
import 'package:turtle/src/editor/editor.dart';
import 'package:turtle/src/editor/box_resizer.dart';
import 'package:turtle/src/editor/socket.dart';
import 'package:turtle/src/model/model.dart';
import 'package:turtle/src/model/program.dart';
import 'package:turtle/src/processor/processor.dart';

class NodeWidget extends StatefulWidget {
  final Program program;

  final Node node;

  final ProgramViewport viewport;

  final void Function(NodeDrag drag) onNodeDragStart;

  final ConnectionDrag? connectionDrag;

  final void Function(ConnectionDrag drag) onConnectionDrag;

  final Stream<PointerEvent> onPointer;

  final Set<Node> selectedNodes;

  final void Function(Node onSelected, bool shift) onSelect;

  final void Function(ResizeDir dir, PointerDownEvent event) onResizeStart;

  const NodeWidget({
    required this.program,
    required this.node,
    required this.viewport,
    super.key,
    required this.onNodeDragStart,
    required this.connectionDrag,
    required this.onConnectionDrag,
    required this.onPointer,
    required this.selectedNodes,
    required this.onSelect,
    required this.onResizeStart,
  });

  @override
  State<NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<NodeWidget> {
  Widget _buildContent(BuildContext context) {
    final theme = ThemeInjector.of(context);
    return Listener(
      onPointerDown: (event) {
        if (event.buttons == kPrimaryMouseButton) {
          widget.onSelect(node, HardwareKeyboard.instance.isShiftPressed);
          widget.onNodeDragStart(
            NodeDrag(
              node: node,
              start: node.offset,
              offset: event.localPosition,
              startTime: DateTime.now(),
              event: event,
            ),
          );
        }
      },
      child: Container(
        width: node.size.width,
        height: node.size.height,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 0, 27, 45),
          borderRadius: theme.node.borderRadius,
          border: selectedNodes.contains(node)
              ? theme.node.selectedBorder
              : theme.node.border,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 0), // changes position of shadow
            ),
          ],
        ),
        child: BoxResizer(
          onResizeStart: (dir, event) => widget.onResizeStart(dir, event),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: theme.node.titleBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  node.processor.label,
                  softWrap: false,
                  style: theme.node.titleTextStyle,
                ),
              ),
              Expanded(
                child: node.preview != null
                    ? PreviewWidget(node.preview)
                    : Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeInjector.of(context);
    return Positioned(
      left: viewport.center.dx + node.offset.dx,
      top: viewport.center.dy + node.offset.dy,
      child: SizedBox(
        width:
            theme.node.socketSize +
            theme.node.socketSpacing +
            node.size.width +
            theme.node.socketSpacing +
            theme.node.socketSize,
        height: node.size.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: theme.node.socketSize + theme.node.socketSpacing,
              top: 0,
              child: _buildContent(context),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: Column(
                spacing: theme.node.socketVerticalMargin,
                children: [
                  SizedBox(height: 25),
                  for (final input in node.inputSockets.indexed)
                    SocketWidget(
                      program: widget.program,
                      index: input.$1,
                      socket: input.$2,
                      node: node,
                      key: ValueKey(input.$2.key),
                      connectionDrag: widget.connectionDrag,
                      onConnectionDrag: widget.onConnectionDrag,
                      onPointer: widget.onPointer,
                    ),
                ],
              ),
            ),
            Positioned(
              left:
                  theme.node.socketSize +
                  theme.node.socketSpacing +
                  node.size.width +
                  theme.node.socketSpacing,
              top: 0,
              child: Column(
                spacing: theme.node.socketVerticalMargin,
                children: [
                  SizedBox(height: 25),
                  for (final output in node.outputSockets.indexed)
                    SocketWidget(
                      program: widget.program,
                      index: output.$1,
                      socket: output.$2,
                      node: node,
                      key: ValueKey(output.$2.key),
                      connectionDrag: widget.connectionDrag,
                      onConnectionDrag: widget.onConnectionDrag,
                      onPointer: widget.onPointer,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  final _subs = <StreamSubscription>[];

  @override
  void initState() {
    super.initState();
    _subs.add(
      node.stream.listen((event) {
        setState(() {});
      }),
    );
    _subs.add(
      viewport.stream.listen((event) {
        setState(() {});
      }),
    );
  }

  @override
  void dispose() {
    while (_subs.isNotEmpty) {
      _subs.removeLast().cancel();
    }
    super.dispose();
  }

  Node get node => widget.node;

  Set<Node> get selectedNodes => widget.selectedNodes;

  ProgramViewport get viewport => widget.viewport;
}

class PreviewWidget extends StatelessWidget {
  final dynamic preview;

  const PreviewWidget(this.preview, {super.key});

  @override
  Widget build(BuildContext context) {
    if (this.preview == null) return Container();
    dynamic preview = this.preview;
    if (preview is List) {
      if (preview.isEmpty) return Container();
      preview = preview.first;
    }
    if (preview is Surface) {
      return RawImage(image: preview.image);
    }
    // TODO other previews
    return Container();
  }
}
