import 'package:turtle/src/model/model.dart';
import 'package:turtle/src/model/program.dart';
import 'package:turtle/src/processor/processor.dart';

class Executer {
  final int frame;
  final Program program;
  Executer({required this.program, required this.frame});

  final _outputs = <String, ProcessorOutput>{};

  Map<String, ProcessorOutput> get outputs => _outputs;

  Future<void> execute() async {
    for (final node in program.nodes) {
      if (_outputs.containsKey(node.id)) continue;
      executeNode(node, {});
    }
  }

  Future<ProcessorOutput> executeNode(Node node, Set<String> visited) async {
    visited.add(node.id);
    final args = [];
    for (final socket in node.inputSockets) {
      final resp = program.getNodeConnectedToSocket('${node.id}.${socket.key}');
      if (resp == null) {
        // TODO what if it is null
        args.add(node.getProperty(socket.id));
        continue;
      }
      final (_, mySocketId, otherNode) = resp;
      if (visited.contains(otherNode.id)) {
        throw Exception('Cycle detected');
      }
      ProcessorOutput? otherOutput = _outputs[otherNode.id];
      otherOutput ??= await executeNode(otherNode, visited);
      args.add(otherOutput.valueBySocketId(mySocketId.split('.').last));
    }
    final input = node.processor.makeInput(args);
    final output = await node.processor.process(input);
    _outputs[node.id] = output;
    node.preview = output.preview;
    return output;
  }
}
