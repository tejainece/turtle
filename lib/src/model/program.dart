import 'package:flutter/widgets.dart';
import 'package:turtle/src/processor/processor.dart';

class Node {
  final Offset offset;
  final String id;
  final List<Port> inputs;
  final List<Port> outputs;
  final Processor processor;
  Node({
    required this.id,
    required this.offset,
    required this.inputs,
    required this.outputs,
    required this.processor,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'offsetX': offset.dx,
    'offsetY': offset.dy,
    'inputs': inputs.map((e) => e.toJson()).toList(),
    'outputs': outputs.map((e) => e.toJson()).toList(),
    'processor': processor.name,
  };

  static Node fromJson(Map json, Map<String, Processor> processors) => Node(
    id: json['id'],
    offset: Offset(json['offsetX'], json['offsetY']),
    inputs: Port.fromJsonList(json['inputs']),
    outputs: Port.fromJsonList(json['outputs']),
    // TODO check that such processor exists
    processor: processors[json['processor']]!,
  );

  static List<Node> fromJsonList(
    List json,
    Map<String, Processor> processors,
  ) => json.cast<Map>().map((e) => Node.fromJson(e, processors)).toList();
}

class Port {
  final String id;
  final String name;
  final String dataType;
  Port({required this.id, required this.name, required this.dataType});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'dataType': dataType,
  };

  static Port fromJson(Map json) =>
      Port(id: json['id'], name: json['name'], dataType: json['dataType']);

  static List<Port> fromJsonList(List json) =>
      json.cast<Map>().map((e) => Port.fromJson(e)).toList();
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

class Program {
  final List<Node> nodes;
  final List<Connection> connections;
  Program({required this.nodes, required this.connections});

  void removeNode(String id) {
    for (final node in nodes) {
      if (node.id != id) continue;

      nodes.remove(node);
      for (final input in node.inputs) {
        removeConnection('${node.id}.${input.id}');
      }
      for (final output in node.outputs) {
        removeConnection('${node.id}.${output.id}');
      }
      break;
    }
  }

  void removeConnection(String portId) {
    for (final connection in connections) {
      if (connection.socketB != portId && connection.socketA != portId) {
        continue;
      }

      connections.remove(connection);
      break;
    }
  }

  void connect(String socketA, String socketB, {List<Offset>? shape}) {
    // TODO verify that socketA exists
    // TODO verify that socketB exists

    // Do not add, if already present
    for (final connection in connections) {
      if (connection.socketA == socketA && connection.socketB == socketB) {
        return;
      }
    }
    connections.add(
      Connection(socketA: socketA, socketB: socketB, shape: shape ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'nodes': nodes.map((e) => e.toJson()).toList(),
    'connections': connections.map((e) => e.toJson()).toList(),
  };

  static Program fromJson(Map json, Map<String, Processor> processors) =>
      Program(
        nodes: Node.fromJsonList(json['nodes'], processors),
        connections: Connection.fromJsonList(json['connections']),
      );
}
