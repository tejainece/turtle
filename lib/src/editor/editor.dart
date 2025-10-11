import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:turtle/src/app/app.dart';
import 'package:turtle/src/editor/node.dart';
import 'package:turtle/src/editor/box_resizer.dart';
import 'package:turtle/src/model/executer.dart';
import 'package:turtle/src/model/model.dart';
import 'package:turtle/src/model/program.dart';

import 'connection.dart';

class ProgramEditor extends StatefulWidget {
  final Program program;
  final Set<Node> selectedNodes;
  final void Function(Set<Node>) onSelectionChange;

  const ProgramEditor({
    required this.program,
    required this.selectedNodes,
    required this.onSelectionChange,
    super.key,
  });

  @override
  State<ProgramEditor> createState() => _ProgramEditorState();
}

class _ProgramEditorState extends State<ProgramEditor> {
  @override
  Widget build(BuildContext context) {
    final theme = ThemeInjector.of(context);

    print(program.connections);

    final content = Container(
      decoration: BoxDecoration(
        color: theme.panelBackground,
        border: theme.panelBorder,
        borderRadius: theme.panelBorderRadius,
      ),
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
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
                if (_nodeResizer != null &&
                    drag.event.pointer == _nodeResizer!.event.pointer) {
                  return;
                }
                _nodeDrag = drag;
              },
              viewport: _viewport,
              connectionDrag: _connectionDrag,
              onConnectionDrag: _onConnectionDrag,
              onPointer: _pointerStream,
              selectedNodes: selectedNodes,
              onSelect: (selected, shift) {
                if (shift) {
                  if (selectedNodes.contains(selected)) {
                    widget.onSelectionChange(selectedNodes..remove(selected));
                  } else {
                    widget.onSelectionChange(selectedNodes..add(selected));
                  }
                } else {
                  widget.onSelectionChange({selected});
                }
              },
              onResizeStart: (dir, event) {
                _nodeResizer = NodeResizer(node: node, event: event, dir: dir);
              },
            ),
        ],
      ),
    );

    return _buildSizeMeasurer(
      context: context,
      child: _registerMouseEvents(
        context: context,
        child: _registerKeyEvents(context: context, child: content),
      ),
    );
  }

  Widget _buildSizeMeasurer({
    required BuildContext context,
    required Widget child,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _viewport.size = constraints.biggest;
        return child;
      },
    );
  }

  Widget _registerMouseEvents({
    required BuildContext context,
    required Widget child,
  }) {
    return Listener(
      onPointerDown: (event) {
        _focus.requestFocus();
        _pointerController.add(event);
        if (_nodeDrag != null && _nodeDrag!.event.pointer == event.pointer) {
          return;
        } else if (_connectionDrag != null &&
            _connectionDrag!.event.pointer == event.pointer) {
          return;
        } else if (_nodeResizer != null &&
            _nodeResizer!.event.pointer == event.pointer) {
          return;
        }
        if (event.buttons == kMiddleMouseButton) {
          setState(() {
            _nodeDrag = null;
            _connectionDrag = null;
            _panOffset = event.localPosition;
            _nodeResizer = null;
          });
        } else if (event.buttons == kPrimaryMouseButton) {
          setState(() {
            _nodeDrag = null;
            _connectionDrag = null;
            _panOffset = null;
            _nodeResizer = null;
            widget.onSelectionChange({});
          });
        }
      },
      onPointerUp: (event) {
        _focus.requestFocus();
        _pointerController.add(event);
        _nodeDrag = null;
        _panOffset = null;
        _nodeResizer = null;
      },
      onPointerHover: (event) {
        _pointerController.add(event);
        if (_connectionDrag != null) {
          setState(() {
            _connectionDrag!.current = event.localPosition;
          });
        }
        if (HardwareKeyboard.instance.isAltPressed) {
          if (event.localPosition.dx > _viewport.size.width - 10) {
            _viewport.center -= Offset(10, 0);
          } else if (event.localPosition.dx < 10) {
            _viewport.center += Offset(10, 0);
          }
          if (event.localPosition.dy > _viewport.size.height - 10) {
            _viewport.center -= Offset(0, 10);
          } else if (event.localPosition.dy < 10) {
            _viewport.center += Offset(0, 10);
          }
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
            _connectionDrag!.current = event.localPosition;
          });
        } else if (_nodeResizer != null) {
          setState(() {
            switch (_nodeResizer!.dir) {
              case ResizeDir.bottom:
                _nodeResizer!.node.size = Size(
                  _nodeResizer!.node.size.width,
                  _nodeResizer!.node.size.height + event.delta.dy,
                );
                break;
              case ResizeDir.top:
                _nodeResizer!.node.offset = Offset(
                  _nodeResizer!.node.offset.dx,
                  _nodeResizer!.node.offset.dy + event.delta.dy,
                );
                _nodeResizer!.node.size = Size(
                  _nodeResizer!.node.size.width,
                  _nodeResizer!.node.size.height - event.delta.dy,
                );
                break;
              case ResizeDir.left:
                _nodeResizer!.node.offset = Offset(
                  _nodeResizer!.node.offset.dx + event.delta.dx,
                  _nodeResizer!.node.offset.dy,
                );
                _nodeResizer!.node.size = Size(
                  _nodeResizer!.node.size.width - event.delta.dx,
                  _nodeResizer!.node.size.height,
                );
                break;
              case ResizeDir.right:
                _nodeResizer!.node.size = Size(
                  _nodeResizer!.node.size.width + event.delta.dx,
                  _nodeResizer!.node.size.height,
                );
                break;
              case ResizeDir.topLeft:
                _nodeResizer!.node.offset = Offset(
                  _nodeResizer!.node.offset.dx + event.delta.dx,
                  _nodeResizer!.node.offset.dy + event.delta.dy,
                );
                _nodeResizer!.node.size = Size(
                  _nodeResizer!.node.size.width - event.delta.dx,
                  _nodeResizer!.node.size.height - event.delta.dy,
                );
                break;
              case ResizeDir.topRight:
                _nodeResizer!.node.offset = Offset(
                  _nodeResizer!.node.offset.dx,
                  _nodeResizer!.node.offset.dy + event.delta.dy,
                );
                _nodeResizer!.node.size = Size(
                  _nodeResizer!.node.size.width + event.delta.dx,
                  _nodeResizer!.node.size.height - event.delta.dy,
                );
                break;
              case ResizeDir.bottomLeft:
                _nodeResizer!.node.offset = Offset(
                  _nodeResizer!.node.offset.dx + event.delta.dx,
                  _nodeResizer!.node.offset.dy,
                );
                _nodeResizer!.node.size = Size(
                  _nodeResizer!.node.size.width - event.delta.dx,
                  _nodeResizer!.node.size.height + event.delta.dy,
                );
                break;
              case ResizeDir.bottomRight:
                _nodeResizer!.node.size = Size(
                  _nodeResizer!.node.size.width + event.delta.dx,
                  _nodeResizer!.node.size.height + event.delta.dy,
                );
                break;
            }
          });
        }
        if (event.localPosition.dx > _viewport.size.width - 10) {
          _viewport.center -= Offset(10, 0);
        } else if (event.localPosition.dx < 10) {
          _viewport.center += Offset(10, 0);
        }
        if (event.localPosition.dy > _viewport.size.height - 10) {
          _viewport.center -= Offset(0, 10);
        } else if (event.localPosition.dy < 10) {
          _viewport.center += Offset(0, 10);
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
      child: child,
    );
  }

  Widget _registerKeyEvents({
    required BuildContext context,
    required Widget child,
  }) {
    return KeyboardListener(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: (event) async {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.delete ||
              event.logicalKey == LogicalKeyboardKey.backspace) {
            for (final node in selectedNodes) {
              program.removeNode(node);
            }
          } else if (event.logicalKey == LogicalKeyboardKey.f5) {
            final executer = Executer(program: program, frame: 0);
            try {
              final watch = Stopwatch()..start();
              await executer.execute();
              print('Executed in ${watch.elapsedMilliseconds}ms');
            } catch (e) {
              print(e);
            }
          }
        }
      },
      child: child,
    );
  }

  final _focus = FocusNode();

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

  Set<Node> get selectedNodes => widget.selectedNodes;

  Program get program => widget.program;

  NodeDrag? _nodeDrag;

  ConnectionDrag? _connectionDrag;

  Offset? _panOffset;

  NodeResizer? _nodeResizer;

  final _subs = <StreamSubscription>[];

  @override
  void initState() {
    super.initState();
    _focus.requestFocus();
    _subs.add(
      program.stream.listen((event) {
        print('refreshing');
        setState(() {});
      }),
    );
  }

  @override
  void dispose() {
    _pointerController.close();
    _focus.dispose();
    _viewport.dispose();
    while (_subs.isNotEmpty) {
      _subs.removeLast().cancel();
    }
    super.dispose();
  }
}

class NodeResizer {
  final Node node;
  final PointerDownEvent event;
  final ResizeDir dir;

  NodeResizer({required this.node, required this.event, required this.dir});
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
