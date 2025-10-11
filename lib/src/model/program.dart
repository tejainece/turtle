import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:turtle/src/app/app.dart';
import 'package:turtle/src/model/model.dart';
import 'package:turtle/src/processor/processor.dart';

class Program {
  final List<Node> _nodes = [];
  final List<Connection> _connections = [];

  final _controller = StreamController<Program>.broadcast();
  late final Stream<Program> stream = _controller.stream;

  Program({required List<Node> nodes, required List<Connection> connections}) {
    for (final node in nodes) {
      addNode(node);
    }
    for (final connection in connections) {
      _connect(
        connection.socketA,
        connection.socketB,
        shape: connection.shape,
        skipEvent: true,
      );
    }
  }

  late final nodes = UnmodifiableListView(_nodes);
  late final connections = UnmodifiableListView(_connections);

  void addNode(Node node) {
    // TODO check that it is not already present
    _nodes.add(node);
    _controller.add(this);
  }

  void removeNode(Node node) {
    _nodes.remove(node);
    for (final input in node.inputSockets) {
      _removeConnection('${node.id}.${input.key}', skipEvent: true);
    }
    for (final output in node.outputSockets) {
      _removeConnection('${node.id}.${output.key}', skipEvent: true);
    }
    _controller.add(this);
  }

  void removeNodeById(String id) {
    for (final node in _nodes) {
      if (node.id != id) continue;
      removeNode(node);
      break;
    }
  }

  void removeConnection(String socketId) {
    _removeConnection(socketId);
  }

  void _removeConnection(String socketId, {bool skipEvent = false}) {
    _connections.removeWhere(
      (connection) =>
          connection.socketB == socketId || connection.socketA == socketId,
    );
    if (!skipEvent) _controller.add(this);
  }

  String? canConnect(String socketAId, String socketBId) {
    String nodeIdA = socketAId.split('.').first;
    String nodeIdB = socketBId.split('.').first;

    if (nodeIdA == nodeIdB) return "Cannot connect a node to itself";

    Node? nodeA = findNodeById(nodeIdA);
    if (nodeA == null) return 'Socket $socketAId is not found in program';
    Node? nodeB = findNodeById(nodeIdB);
    if (nodeB == null) return 'Socket $socketBId is not found in program';

    String socketAKey = socketAId.split('.').skip(1).join('.');
    String socketBKey = socketBId.split('.').skip(1).join('.');

    ProcessorSocket? socketA = nodeA.findSocketByKey(socketAKey);
    if (socketA == null) return 'Socket $socketAId is not found in program';
    ProcessorSocket? socketB = nodeB.findSocketByKey(socketBKey);
    if (socketB == null) return 'Socket $socketBId is not found in program';

    if (socketA.isInput && socketB.isInput) {
      return "Cannot connect two input sockets";
    }
    if (!socketA.isInput && !socketB.isInput) {
      return "Cannot connect two output sockets";
    }
    if (socketA.dataType != socketB.dataType) {
      return "Cannot connect sockets of different data types";
    }

    return null;
  }

  String? connect(String socketAId, String socketBId, {List<Offset>? shape}) =>
      _connect(socketAId, socketBId, shape: shape);

  String? _connect(
    String socketAId,
    String socketBId, {
    List<Offset>? shape,
    bool skipEvent = false,
  }) {
    // Do not add, if already present
    for (final connection in _connections) {
      if (connection.socketA == socketAId && connection.socketB == socketBId) {
        return null;
      }
    }

    final err = canConnect(socketAId, socketBId);
    if (err != null) return err;
    _connections.add(
      Connection(socketA: socketAId, socketB: socketBId, shape: shape ?? []),
    );
    if (!skipEvent) {
      _controller.add(this);
    }

    return null;
  }

  Node? findNodeById(String id) {
    for (final node in _nodes) {
      if (node.id != id) continue;
      return node;
    }
    return null;
  }

  DataType? getSocketDataType(String socketId) {
    final nodeId = socketId.split('.').first;
    final node = findNodeById(nodeId);
    if (node == null) return null;
    final socId = socketId.split('.').skip(1).join('.');

    for (final input in node.inputSockets) {
      if (input.key != socId) continue;
      return input.dataType;
    }
    for (final output in node.outputSockets) {
      if (output.key != socId) continue;
      return output.dataType;
    }
    return null;
  }

  Offset? getConnectionOffset(String socketId, MyTheme theme) {
    final nodeId = socketId.split('.').first;
    final node = findNodeById(nodeId);
    if (node == null) return null;
    final socKey = socketId.split('.').skip(1).join('.');
    return node.getSocketOffset(socKey, theme.node)?.offset;
  }

  (Node, Node)? getConnectionNodes(String socketAId, String socketBId) {
    String nodeIdA = socketAId.split('.').first;
    String nodeIdB = socketBId.split('.').first;

    Node? nodeA = findNodeById(nodeIdA);
    if (nodeA == null) return null;
    Node? nodeB = findNodeById(nodeIdB);
    if (nodeB == null) return null;
    return (nodeA, nodeB);
  }

  Connection? getConnectionBySocket(String socketId) {
    for (final connection in _connections) {
      if (connection.socketA == socketId || connection.socketB == socketId) {
        return connection;
      }
    }
    return null;
  }

  (Connection, String, Node)? getNodeConnectedToSocket(String socketId) {
    final connection = getConnectionBySocket(socketId);
    if (connection == null) return null;
    String mySocketId = connection.socketA;
    if (mySocketId == socketId) {
      mySocketId = connection.socketB;
    }
    String nodeId = mySocketId.split('.').first;
    final node = findNodeById(nodeId);
    if (node == null) return null;
    return (connection, mySocketId, node);
  }

  ConnectionMeta? getConnectionData(Connection connection, MyTheme theme) {
    final nodeA = findNodeById(connection.socketA.split('.').first);
    if (nodeA == null) return null;
    final nodeB = findNodeById(connection.socketB.split('.').first);
    if (nodeB == null) return null;

    final socketAKey = connection.socketA.split('.').skip(1).join('.');
    final socketBKey = connection.socketB.split('.').skip(1).join('.');

    final offsetA = nodeA.getSocketOffset(socketAKey, theme.node);
    if (offsetA == null) return null;
    final offsetB = nodeB.getSocketOffset(socketBKey, theme.node);
    if (offsetB == null) return null;

    return ConnectionMeta(
      dataType: offsetA.socket.dataType,
      socketAOffset: offsetA.offset,
      socketBOffset: offsetB.offset,
    );
  }

  Future<void> dispose() async {
    await _controller.close();
    for (final node in _nodes) {
      await node.dispose();
    }
  }

  Map<String, dynamic> toJson() => {
    'nodes': _nodes.map((e) => e.toJson()).toList(),
    'connections': _connections.map((e) => e.toJson()).toList(),
  };

  static Program fromJson(Map json, Map<String, Processor> processors) =>
      Program(
        nodes: Node.fromJsonList(json['nodes'], processors),
        connections: Connection.fromJsonList(json['connections']),
      );
}

class ConnectionMeta {
  final DataType dataType;
  final Offset socketAOffset;
  final Offset socketBOffset;
  ConnectionMeta({
    required this.dataType,
    required this.socketAOffset,
    required this.socketBOffset,
  });
}
