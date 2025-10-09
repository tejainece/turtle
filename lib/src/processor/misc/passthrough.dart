import 'package:turtle/src/processor/processor.dart';

class PassthroughInput implements ProcessorInput {
  final dynamic input;

  PassthroughInput({required this.input});

  static PassthroughInput fromArgs(List args) {
    return PassthroughInput(input: args[0]);
  }

  @override
  late final List<ProcessorSocket> sockets = mySockets;

  static final List<ProcessorSocket> mySockets = [
    ProcessorSocket(
      label: 'Input',
      dataType: DataType.number,
      id: 'input',
      isInput: true,
    ),
  ];
}

class PassthroughOutput implements ProcessorOutput {
  final dynamic output;

  PassthroughOutput({required this.output});

  @override
  List<dynamic> get asArgs => [output];

  @override
  Null get preview => null;

  @override
  List<ProcessorSocket> get sockets => mySockets;

  static final List<ProcessorSocket> mySockets = [
    ProcessorSocket(
      label: 'Output',
      dataType: DataType.number,
      id: 'output',
      isInput: false,
    ),
  ];
}

class PassthroughNode
    implements Processor<PassthroughOutput, PassthroughInput> {
  @override
  Future<PassthroughOutput> process(PassthroughInput input) async =>
      PassthroughOutput(output: input.input);

  @override
  PassthroughInput makeInput(List<dynamic> args) =>
      PassthroughInput.fromArgs(args);

  @override
  List<ProcessorSocket> get inputSockets => PassthroughInput.mySockets;

  @override
  List<ProcessorSocket> get outputSockets => PassthroughOutput.mySockets;

  @override
  final String label = 'Passthrough';
}
