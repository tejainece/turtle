import 'package:flutter/widgets.dart';
import 'package:turtle/src/processor/processor.dart';

class Node {
  Offset offset;
  Size size;
  final String id;
  final Processor processor;

  dynamic preview;

  Node({
    required this.id,
    required this.offset,
    required this.size,
    required this.processor,
  });

  List<ProcessorSocket> get inputSockets => processor.inputSockets;
  List<ProcessorSocket> get outputSockets => processor.outputSockets;

  ProcessorSocket? findSocket(String key) {
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
