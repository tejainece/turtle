import 'package:flutter/painting.dart';
import 'package:turtle/src/editor/editor.dart';
import 'package:turtle/src/model/model.dart';
import 'package:turtle/src/processor/processor.dart';

class Program {
  final List<Node> nodes;
  final List<Connection> connections;
  Program({required this.nodes, required this.connections});

  void removeNode(String id) {
    for (final node in nodes) {
      if (node.id != id) continue;

      nodes.remove(node);
      for (final input in node.inputSockets) {
        removeConnection('${node.id}.${input.key}');
      }
      for (final output in node.outputSockets) {
        removeConnection('${node.id}.${output.key}');
      }
      break;
    }
  }

  void removeConnection(String socketId) {
    for (final connection in connections) {
      if (connection.socketB != socketId && connection.socketA != socketId) {
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

  DataType? getConnectionDataType(String socketId) {
    final nodeId = socketId.split('.').first;
    final socId = socketId.split('.').skip(1).join('.');
    for (final node in nodes) {
      if (node.id != nodeId) continue;
      for (final input in node.inputSockets) {
        if (input.key != socId) continue;
        return input.dataType;
      }
      for (final output in node.outputSockets) {
        if (output.key != socId) continue;
        return output.dataType;
      }
    }
    return null;
  }

  Offset? getConnectionOffset(String socketId) {
    final nodeId = socketId.split('.').first;
    final socId = socketId.split('.').skip(1).join('.');
    for (final node in nodes) {
      if (node.id != nodeId) continue;
      for (final input in node.inputSockets.indexed) {
        if (input.$2.key != socId) continue;
        return node.offset +
            Offset(
              SocketWidget.size / 2,
              25 +
                  5 +
                  SocketWidget.size / 2 +
                  input.$1 * (SocketWidget.size + 5),
            )
        /*Offset(
              -SocketWidget.size / 2 - 5,
              25 +
                  SocketWidget.size / 2 +
                  input.$1 * (SocketWidget.size + 5) +
                  SocketWidget.size / 2,
            )*/
        ;
      }
      for (final output in node.outputSockets.indexed) {
        if (output.$2.key != socId) continue;
        return node.offset +
            Offset(
              SocketWidget.size +
                  5 +
                  node.size.width +
                  5 +
                  SocketWidget.size / 2,
              25 +
                  5 +
                  SocketWidget.size / 2 +
                  output.$1 * (SocketWidget.size + 5),
            )
        /*Offset(
              node.size.width + SocketWidget.size / 2 + 5,
              25 +
                  SocketWidget.size / 2 +
                  output.$1 * (SocketWidget.size + 5) +
                  SocketWidget.size / 2,
            )*/
        ;
      }
    }
    return null;
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

class Executer {
  final Program program;
  Executer({required this.program});

  void execute() {
    // TODO
  }
}
