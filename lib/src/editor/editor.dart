import 'dart:async';

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
        _pointerController.add(event);
        if (_nodeDrag != null && _nodeDrag!.event.pointer == event.pointer) {
          return;
        } else if (_connectionDrag != null &&
            _connectionDrag!.event.pointer == event.pointer) {
          return;
        }
        setState(() {
          _nodeDrag = null;
          _connectionDrag = null;
          _panOffset = null;
        });
        if (event.buttons == kMiddleMouseButton) {
          setState(() {
            _nodeDrag = null;
            _connectionDrag = null;
            _panOffset = event.localPosition;
          });
        }
      },
      onPointerUp: (event) {
        _pointerController.add(event);
        _nodeDrag = null;
        _panOffset = null;
      },
      onPointerHover: (event) {
        _pointerController.add(event);
        if (_connectionDrag != null) {
          setState(() {
            _connectionDrag!.current = event.localPosition.scale(
              _viewport.scale,
              _viewport.scale,
            );
          });
        }
      },
      onPointerMove: (event) {
        _pointerController.add(event);
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
            _connectionDrag!.current = event
                .localPosition /*.scale(
              _viewport.scale,
              _viewport.scale,
            )*/;
          });
        }
      },
      onPointerSignal: (event) {
        _pointerController.add(event);
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
                  onPointer: _pointerStream,
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
                  onPointer: _pointerStream,
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

  final _pointerController = StreamController<PointerEvent>.broadcast();
  late final _pointerStream = _pointerController.stream;

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
    _pointerController.close();
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
  Size _size;
  Offset _center;
  double _scale;

  final _controller = StreamController<ProgramViewport>.broadcast();
  late final Stream<ProgramViewport> stream = _controller.stream;

  ProgramViewport({
    required Size size,
    required Offset center,
    required double scale,
  }) : _size = size,
       _center = center,
       _scale = scale;

  Size get size => _size;

  set size(Size value) {
    if (value == _size) return;
    _size = value;
    _controller.add(this);
  }

  Offset get center => _center;

  set center(Offset value) {
    if (value == _center) return;
    _center = value;
    _controller.add(this);
  }

  double get scale => _scale;

  set scale(double value) {
    if (value < 0.2) {
      value = 0.2;
    }
    if (value == _scale) return;
    _scale = value;
    _controller.add(this);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
