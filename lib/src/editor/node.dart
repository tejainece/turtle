import 'package:flutter/material.dart';
import 'package:turtle/src/editor/editor.dart';
import 'package:turtle/src/editor/socket.dart';
import 'package:turtle/src/model/model.dart';
import 'package:turtle/src/model/program.dart';

class NodeWidget extends StatefulWidget {
  final Program program;

  final Node node;

  final ProgramViewport viewport;

  final void Function(NodeDrag drag) onNodeDragStart;

  final ConnectionDrag? connectionDrag;

  final void Function(ConnectionDrag drag) onConnectionDrag;

  const NodeWidget({
    required this.program,
    required this.node,
    required this.viewport,
    super.key,
    required this.onNodeDragStart,
    required this.connectionDrag,
    required this.onConnectionDrag,
  });

  @override
  State<NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<NodeWidget> {
  Widget _buildContent(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        widget.onNodeDragStart(
          NodeDrag(
            node: node,
            start: node.offset,
            offset: event.localPosition,
            startTime: DateTime.now(),
            event: event,
          ),
        );
      },
      child: Container(
        width: node.size.width,
        height: node.size.height,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 0, 27, 45),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color.fromARGB(255, 0, 48, 111),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 0), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 0, 46, 107),
                borderRadius: /*BorderRadius.circular(10)*/ BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Text(
                node.processor.label,
                softWrap: false,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.fade,
                ),
              ),
            ),
            Expanded(child: Stack(children: [

                ],
              )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: viewport.center.dx + node.offset.dx,
      top: viewport.center.dy + node.offset.dy,
      child: SizedBox(
        width:
            SocketWidget.size +
            SocketWidget.spacingH +
            node.size.width +
            SocketWidget.spacingH +
            SocketWidget.size,
        height: node.size.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: SocketWidget.size + SocketWidget.spacingH,
              top: 0,
              child: _buildContent(context),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: Column(
                spacing: SocketWidget.spacingH,
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
                    ),
                ],
              ),
            ),
            Positioned(
              left:
                  SocketWidget.size +
                  SocketWidget.spacingH +
                  node.size.width +
                  SocketWidget.spacingH,
              top: 0,
              child: Column(
                spacing: SocketWidget.spacingH,
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
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Node get node => widget.node;

  ProgramViewport get viewport => widget.viewport;
}
