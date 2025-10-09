import 'package:turtle/src/processor/processor.dart';

class NumberInput implements ProcessorInput {
  NumberInput();

  static NumberInput fromArgs(List args) {
    return NumberInput();
  }

  @override
  late final List<ProcessorSocket> sockets = mySockets;

  static final List<ProcessorSocket> mySockets = [];
}

class NumberOutput implements ProcessorOutput {
  final num output;

  NumberOutput({required this.output});

  @override
  List<dynamic> get asArgs => [output];

  @override
  num get preview => output;

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

class NumberNode implements Processor<NumberOutput, NumberInput> {
  @override
  Future<NumberOutput> process(NumberInput input) async =>
      // TODO
      NumberOutput(output: 2);

  @override
  NumberInput makeInput(List<dynamic> args) => NumberInput.fromArgs(args);

  @override
  List<ProcessorSocket> get inputSockets => NumberInput.mySockets;

  @override
  List<ProcessorSocket> get outputSockets => NumberOutput.mySockets;

  @override
  final String label = 'Number';
}
