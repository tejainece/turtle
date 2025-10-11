import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:turtle/src/app/app.dart';
import 'package:turtle/src/app/theme.dart';
import 'package:turtle/src/processor/processor.dart';

class Node {
  Offset _offset;
  Size _size;
  final String id;
  final Processor processor;

  dynamic _preview;

  final _controller = StreamController<Node>.broadcast();
  late final Stream<Node> stream = _controller.stream;

  final Map<String, dynamic> _properties;

  Node({
    required this.id,
    required Offset offset,
    required Size size,
    required this.processor,
    Map<String, dynamic>? properties,
  }) : _offset = offset,
       _size = size,
       _properties = Map.from(properties ?? {});

  Offset get offset => _offset;
  set offset(Offset value) {
    if (value == _offset) return;
    _offset = value;
    _controller.add(this);
  }

  Size get size => _size;

  set size(Size value) {
    if (value.width < 30) {
      value = Size(30, value.height);
    }
    if (value.height < 30) {
      value = Size(value.width, 30);
    }
    if (value == _size) return;
    _size = value;
    _controller.add(this);
  }

  dynamic get preview => _preview;
  set preview(dynamic value) {
    if (value == _preview) return;
    _preview = value;
    _controller.add(this);
  }

  List<ProcessorSocket> get inputSockets => processor.inputSockets;
  List<ProcessorSocket> get outputSockets => processor.outputSockets;

  ProcessorSocket? findSocketByKey(String key) {
    for (final socket in inputSockets) {
      if (socket.key != key) continue;
      return socket;
    }
    for (final socket in outputSockets) {
      if (socket.key != key) continue;
      return socket;
    }
    return null;
  }

  void setProperty(String socketId, dynamic value) {
    // TODO check that socket is input
    // TODO check that socket data type matches
    _properties[socketId] = value;
    _controller.add(this);
  }

  dynamic getProperty(String socketId) {
    // TODO check that socket is input
    return _properties[socketId];
  }

  ({ProcessorSocket socket, Offset offset})? getSocketOffset(
    String socKey,
    NodeTheme theme,
  ) {
    for (final input in inputSockets.indexed) {
      if (input.$2.key != socKey) continue;
      return (
        socket: input.$2,
        offset:
            offset +
            Offset(
              theme.socketSize / 2,
              25 +
                  theme.socketVerticalMargin +
                  theme.socketSize / 2 +
                  input.$1 * (theme.socketSize + 5),
            ),
      );
    }
    for (final output in outputSockets.indexed) {
      if (output.$2.key != socKey) continue;
      return (
        socket: output.$2,
        offset:
            offset +
            Offset(
              theme.socketSize +
                  theme.socketSpacing +
                  size.width +
                  theme.socketSpacing +
                  theme.socketSize / 2,
              25 +
                  theme.socketVerticalMargin +
                  theme.socketSize / 2 +
                  output.$1 * (theme.socketSize + 5),
            ),
      );
    }
    return null;
  }

  Future<void> dispose() async {
    await _controller.close();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'offsetX': offset.dx,
    'offsetY': offset.dy,
    'width': size.width,
    'height': size.height,
    'processor': processor.label,
  };

  static Node fromJson(Map json, Map<String, Processor> processors) => Node(
    id: json['id'],
    offset: Offset(json['offsetX'], json['offsetY']),
    size: Size(json['width'], json['height']),
    // TODO check that such processor exists
    processor: processors[json['processor']]!,
  );

  static List<Node> fromJsonList(
    List json,
    Map<String, Processor> processors,
  ) => json.cast<Map>().map((e) => Node.fromJson(e, processors)).toList();
}

class Connection {
  final String socketA;
  final String socketB;
  final List<Offset> shape;

  Connection({
    required this.socketA,
    required this.socketB,
    required this.shape,
  });

  Map<String, dynamic> toJson() => {
    'socketA': socketA,
    'socketB': socketB,
    if (shape.isNotEmpty) 'shape': shape.map((e) => [e.dx, e.dy]).toList(),
  };

  static Connection fromJson(Map json) => Connection(
    socketA: json['socketA'],
    socketB: json['socketB'],
    shape: (json['shape'] ?? [])
        .cast<List>()
        .map((e) => Offset(e[0], e[1]))
        .toList(),
  );

  static List<Connection> fromJsonList(List json) =>
      json.cast<Map>().map((e) => Connection.fromJson(e)).toList();
}
