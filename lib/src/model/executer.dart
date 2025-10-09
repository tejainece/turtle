import 'package:turtle/src/model/program.dart';
import 'package:turtle/src/processor/processor.dart';

class Executer {
  final int frame;
  final Program program;
  Executer({required this.program, required this.frame});

  void execute() {
    final outputs = <String, ProcessorOutput>{
      // TODO
    };
    for (final node in program.nodes) {
      for (final socket in node.inputSockets) {
        // TODO
      }
      // TODO process the node
    }
  }
}
