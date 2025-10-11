import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:turtle/src/app/app.dart';
import 'package:turtle/src/editor/editor.dart';
import 'package:turtle/src/model/model.dart';
import 'package:turtle/src/model/program.dart';
import 'package:turtle/src/processor/processor.dart';

class SocketWidget extends StatefulWidget {
  final Program program;
  final Node node;
  final int index;
  final ProcessorSocket socket;
  final ConnectionDrag? connectionDrag;
  final void Function(ConnectionDrag drag) onConnectionDrag;
  final Stream<PointerEvent> onPointer;

  const SocketWidget({
    required this.program,
    required this.index,
    required this.socket,
    required this.node,
    super.key,
    required this.connectionDrag,
    required this.onConnectionDrag,
    required this.onPointer,
  });

  @override
  State<SocketWidget> createState() => _SocketWidgetState();
}

class _SocketWidgetState extends State<SocketWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = ThemeInjector.of(context);
    Widget content = SizedBox(
      width: theme.node.socketSize,
      height: theme.node.socketSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: _onPointerEvent,
              child: Container(
                width: theme.node.socketSize,
                height: theme.node.socketSize,
                decoration: BoxDecoration(
                  color: _hovering != null
                      ? (_hovering!.message != null
                            ? Colors.red
                            : socket.dataType.col)
                      : null,
                  border: Border.all(
                    color: socket.dataType.col,
                    width: theme.node.socketThickness,
                  ),
                  borderRadius: BorderRadius.circular(
                    theme.node.socketSize / 2,
                  ),
                ),
              ),
            ),
          ),
          if (_hovering != null)
            Positioned(
              left: socket.isInput
                  ? theme.node.socketSize +
                        theme.node.socketVerticalMargin +
                        theme.node.socketVerticalMargin +
                        10
                  : null,
              right: socket.isInput
                  ? null
                  : theme.node.socketSize +
                        theme.node.socketVerticalMargin +
                        theme.node.socketVerticalMargin +
                        10,
              top: 0,
              child: _buildName(),
            ),
        ],
      ),
    );
    if (_hovering != null && _hovering!.message != null) {
      content = Tooltip(message: _hovering!.message!, child: content);
    }
    return MouseRegion(
      opaque: false,
      hitTestBehavior: HitTestBehavior.translucent,
      onEnter: (event) {
        setState(() {
          String? message;
          if (connectionDrag != null) {
            message = program.canConnect(
              connectionDrag!.socketId,
              '${node.id}.${socket.key}',
            );
          }
          _hovering = _SocketHoverData(message: message);
        });
      },
      onExit: (event) {
        setState(() {
          _hovering = null;
        });
      },
      child: content,
    );
  }

  Widget _buildName() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: socket.dataType.col, //const Color.fromARGB(255, 44, 44, 44),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            socket.label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            socket.dataType.name,
            style: TextStyle(
              color: socket.dataType.col,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _onPointerEvent(PointerEvent event) {
    if (event is PointerDownEvent) {
      if (event.buttons == kPrimaryMouseButton) {
        widget.onConnectionDrag(
          ConnectionDrag(
            socketId: '${node.id}.${socket.key}',
            event: event,
            current: event.localPosition,
          ),
        );
      }
    }
  }

  _SocketHoverData? _hovering;

  Program get program => widget.program;

  Node get node => widget.node;

  ProcessorSocket get socket => widget.socket;

  ConnectionDrag? get connectionDrag => widget.connectionDrag;
}

class _SocketHoverData {
  final String? message;
  _SocketHoverData({required this.message});
}
