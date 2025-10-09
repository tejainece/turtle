import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:turtle/src/model/model.dart';
import 'package:turtle/src/model/program.dart';
import 'package:turtle/src/processor/processor.dart';

class ProgramEditor extends StatefulWidget {
  final Program program;

  const ProgramEditor({required this.program, super.key});

  @override
  State<ProgramEditor> createState() => _ProgramEditorState();
}

class _ProgramEditorState extends State<ProgramEditor> {
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerUp: (event) {
        _nodeDrag = null;
        _panOffset = null;
      },
      onPointerMove: (event) {
        if (_nodeDrag != null) {
          setState(() {
            _nodeDrag!.node.offset += event.delta;
          });
        } else if (_panOffset != null) {
          setState(() {
            _viewport.center += event.delta;
          });
        } else if (_connectionDrag != null) {
          setState(() {
            _connectionDrag!.current = event.localPosition;
          });
        }
      },
      onPointerDown: (event) {
        if (_nodeDrag != null && _nodeDrag!.event.pointer == event.pointer) {
          return;
        } else if (_connectionDrag != null &&
            _connectionDrag!.event.pointer == event.pointer) {
          return;
        }
        setState(() {
          _nodeDrag = null;
          _connectionDrag = null;
          _panOffset = event.localPosition;
        });
      },
      child: Container(
        decoration: BoxDecoration(color: const Color.fromARGB(255, 47, 47, 47)),
        child: Stack(
          children: [
            for (final connection in program.connections)
              ConnectionWidget(
                connection: connection,
                program: program,
                key: ValueKey(connection),
                viewport: _viewport,
              ),
            if (_connectionDrag != null)
              ConnectionDragWidget(
                program: program,
                socket: _connectionDrag!.socketId,
                viewport: _viewport,
                current: Offset(0, 0),
              ),
            for (final node in program.nodes)
              NodeWidget(
                node,
                key: ValueKey(node.id),
                onNodeDragStart: (drag) {
                  _nodeDrag = drag;
                },
                viewport: _viewport,
                onConnectionDrag: _onConnectionDrag,
              ),
          ],
        ),
      ),
    );
  }

  void _onConnectionDrag(ConnectionDrag drag) {}

  final Viewport _viewport = Viewport(size: Size.zero, center: Offset.zero);

  Program get program => widget.program;

  NodeDrag? _nodeDrag;

  ConnectionDrag? _connectionDrag;

  Offset? _panOffset;

  @override
  void dispose() {
    super.dispose();
  }
}

class NodeDrag {
  final Node node;
  final Offset start;
  final Offset offset;
  final DateTime startTime;
  final PointerEvent event;
  NodeDrag({
    required this.node,
    required this.start,
    required this.offset,
    required this.startTime,
    required this.event,
  });
}

class ConnectionDrag {
  final String socketId;
  final PointerEvent event;
  Offset current;
  ConnectionDrag({
    required this.socketId,
    required this.event,
    required this.current,
  });
}

class NodeWidget extends StatefulWidget {
  final Node node;

  final Viewport viewport;

  final void Function(NodeDrag drag) onNodeDragStart;

  final void Function(ConnectionDrag drag) onConnectionDrag;

  const NodeWidget(
    this.node, {
    required this.viewport,
    super.key,
    required this.onNodeDragStart,
    required this.onConnectionDrag,
  });

  @override
  State<NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<NodeWidget> {
  Widget _buildContent(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        // print('${event.localPosition} ${event.localDelta} ${event.position}');
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            spacing: 5,
            children: [
              SizedBox(height: 25),
              for (final input in node.inputSockets.indexed)
                SocketWidget(
                  index: input.$1,
                  socket: input.$2,
                  node: node,
                  key: ValueKey(input.$2.key),
                  onConnectionDrag: widget.onConnectionDrag,
                ),
            ],
          ),
          SizedBox(width: 5),
          _buildContent(context),
          SizedBox(width: 5),
          Column(
            spacing: 5,
            children: [
              SizedBox(height: 25),
              for (final output in node.outputSockets.indexed)
                SocketWidget(
                  index: output.$1,
                  socket: output.$2,
                  node: node,
                  key: ValueKey(output.$2.key),
                  onConnectionDrag: widget.onConnectionDrag,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Node get node => widget.node;

  Viewport get viewport => widget.viewport;
}

class SocketWidget extends StatefulWidget {
  final Node node;
  final int index;
  final ProcessorSocket socket;
  final void Function(ConnectionDrag drag) onConnectionDrag;

  const SocketWidget({
    required this.index,
    required this.socket,
    required this.node,
    super.key,
    required this.onConnectionDrag,
  });

  @override
  State<SocketWidget> createState() => _SocketWidgetState();

  static const double size = 20;

  static const double borderSize = 4;
}

class _SocketWidgetState extends State<SocketWidget> {
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        widget.onConnectionDrag(
          ConnectionDrag(
            socketId: '${node.id}.${socket.key}',
            event: event,
            current: event.localPosition,
          ),
        );
      },
      child: MouseRegion(
        opaque: true,
        hitTestBehavior: HitTestBehavior.opaque,
        onEnter: (event) {
          setState(() {
            _hovering = true;
          });
        },
        onExit: (event) {
          setState(() {
            _hovering = false;
          });
        },
        child: Container(
          width: SocketWidget.size,
          height: SocketWidget.size,
          decoration: BoxDecoration(
            color: _hovering ? socket.dataType.col : null,
            border: Border.all(
              color: socket.dataType.col,
              width: SocketWidget.borderSize,
            ),
            borderRadius: BorderRadius.circular(SocketWidget.size / 2),
          ),
        ),
      ),
    );
  }

  bool _hovering = false;

  Node get node => widget.node;

  ProcessorSocket get socket => widget.socket;
}

class ConnectionWidget extends StatelessWidget {
  final Program program;
  final Connection connection;
  final Viewport viewport;

  const ConnectionWidget({
    required this.connection,
    required this.program,
    required this.viewport,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      /*rect: Rect.fromPoints(
        program.getConnectionOffset(connection.socketA)!,
        program.getConnectionOffset(connection.socketB)!,
      ),*/
      child: CustomPaint(
        painter: ConnectionPainter(
          start:
              viewport.center +
              program.getConnectionOffset(connection.socketA)!,
          end:
              viewport.center +
              program.getConnectionOffset(connection.socketB)!,
          color: program.getConnectionDataType(connection.socketA)!.col,
        ),
      ),
    );
  }
}

class ConnectionDragWidget extends StatelessWidget {
  final Program program;
  final String socket;
  final Offset current;
  final Viewport viewport;

  const ConnectionDragWidget({
    required this.program,
    required this.socket,
    required this.viewport,
    required this.current,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: ConnectionPainter(
          start: viewport.center + program.getConnectionOffset(socket)!,
          end: current,
          color: program.getConnectionDataType(socket)!.col,
        ),
      ),
    );
  }
}

class ConnectionPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;

  ConnectionPainter({
    required this.start,
    required this.end,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;

    final Path path = Path();

    path.moveTo(start.dx, start.dy);
    path.lineTo(end.dx, end.dy);

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 4.0
        ..isAntiAlias = true
        ..imageFilter = ImageFilter.blur(sigmaX: 3, sigmaY: 3)
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..strokeWidth = 4.0
        ..isAntiAlias = true
        ..imageFilter = ImageFilter.blur(sigmaX: 2, sigmaY: 2)
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(path, paint);

    canvas.drawCircle(
      start,
      5,
      Paint()
        ..color = color
        ..isAntiAlias = true
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      end,
      5,
      Paint()
        ..color = color
        ..isAntiAlias = true
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class Viewport {
  Size size;
  Offset center;
  Viewport({required this.size, required this.center});
}
