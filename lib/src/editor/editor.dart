import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:turtle/src/editor/node.dart';
import 'package:turtle/src/model/model.dart';
import 'package:turtle/src/model/program.dart';

import 'connection.dart';

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
      onPointerDown: (event) {
        if (_nodeDrag != null && _nodeDrag!.event.pointer == event.pointer) {
          return;
        } else if (_connectionDrag != null &&
            _connectionDrag!.event.pointer == event.pointer) {
          return;
        }
        _nodeDrag = null;
        _connectionDrag = null;
        _panOffset = null;
        if (event.buttons == kMiddleMouseButton) {
          setState(() {
            _nodeDrag = null;
            _connectionDrag = null;
            _panOffset = event.localPosition;
          });
        }
      },
      onPointerUp: (event) {
        _nodeDrag = null;
        _panOffset = null;
      },
      onPointerHover: (event) {
        if (_connectionDrag != null) {
          setState(() {
            _connectionDrag!.current = event.localPosition;
          });
        }
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
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          setState(() {
            _viewport.scale += event.scrollDelta.dy.isNegative ? -0.05 : 0.05;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(color: const Color.fromARGB(255, 47, 47, 47)),
        child: Transform.scale(
          scale: _viewport.scale,
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
                  current: _connectionDrag!.current,
                ),
              for (final node in program.nodes)
                NodeWidget(
                  node: node,
                  program: program,
                  key: ValueKey(node.id),
                  onNodeDragStart: (drag) {
                    _nodeDrag = drag;
                  },
                  viewport: _viewport,
                  connectionDrag: _connectionDrag,
                  onConnectionDrag: _onConnectionDrag,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onConnectionDrag(ConnectionDrag drag) {
    if (_connectionDrag == null) {
      _connectionDrag = drag;
      _nodeDrag = null;
      _panOffset = null;
      return;
    }
    program.connect(_connectionDrag!.socketId, drag.socketId);
    _connectionDrag = null;
    setState(() {});
  }

  final ProgramViewport _viewport = ProgramViewport(
    size: Size.zero,
    center: Offset.zero,
    scale: 1,
  );

  String? _selectedNode;

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

class ProgramViewport {
  Size size;
  Offset center;
  double _scale;
  ProgramViewport({
    required this.size,
    required this.center,
    required double scale,
  }) : _scale = scale;

  double get scale => _scale;

  set scale(double value) {
    _scale = value;
    if (_scale < 0.2) {
      scale = 0.2;
    }
  }
}
